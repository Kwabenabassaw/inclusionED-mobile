/**
 * TextNormalizer — pure TypeScript module
 *
 * Produces two aligned outputs from one source:
 *   displayText  — original, clean text shown on screen (NEVER modified)
 *   ssml         — SSML string sent to AWS Polly
 *   alignmentMap — array mapping each speech token index → displayText char range
 *
 * Rules implemented: R1-R22 per the approved normalization table.
 * Decision points (finalized):
 *   - Slash: word-pairs → "or"; acronyms/paths/digits → "slash"
 *   - URLs: "a web link" default; clean short domain → domain name only
 *   - Code: < 8 words inline → read literally; longer → "a code example follows, check the screen to view it"
 *   - Units (km, Mbps, etc.): left to Polly built-in; not in expansion table
 */

export interface AlignmentEntry {
  speechIdx: number;   // 0-based index of the speech token Polly will fire a Speech Mark for
  displayStart: number; // char offset in displayText where highlight begins
  displayEnd: number;   // char offset in displayText where highlight ends (exclusive)
}

export interface NormalizerOutput {
  displayText: string;
  ssml: string;
  alignmentMap: AlignmentEntry[];
}

// ─── Abbreviation expansion table ─────────────────────────────────────────────
const ABBREVIATIONS: Record<string, string> = {
  'e.g.': 'for example',
  'i.e.': 'that is',
  'etc.': 'and so on',
  'vs.': 'versus',
  'vs': 'versus',
  'Dr.': 'Doctor',
  'Mr.': 'Mister',
  'Mrs.': 'Missus',
  'Ms.': 'Miss',
  'Prof.': 'Professor',
  'Fig.': 'Figure',
  'Eq.': 'Equation',
  'Ref.': 'Reference',
  'Sec.': 'Section',
  'Ch.': 'Chapter',
  'Vol.': 'Volume',
  'no.': 'number',
  'No.': 'Number',
  'approx.': 'approximately',
  'dept.': 'department',
  'est.': 'established',
};

// ─── Helpers ──────────────────────────────────────────────────────────────────

function escapeXml(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

function isAllCapsOrDigit(s: string): boolean {
  return /^[A-Z0-9]+$/.test(s);
}

function isCommonWord(s: string): boolean {
  // Rough heuristic: lowercase, only letters, no digits
  return /^[a-z]+$/.test(s);
}

function slashRule(left: string, right: string): string {
  // Decision: word-pairs expressing alternatives → "or"
  // Acronyms, paths, digit-involved → "slash"
  if (isCommonWord(left) && isCommonWord(right)) {
    return `${left} or ${right}`;
  }
  return `${left} slash ${right}`;
}

function isShortDomain(url: string): boolean {
  // Matches a clean domain like "khanacademy.org" (no protocol, no path)
  return /^[a-zA-Z0-9-]+\.[a-zA-Z]{2,6}$/.test(url);
}

function isFullUrl(token: string): boolean {
  return /^https?:\/\//i.test(token) || /^www\./i.test(token);
}

function isEmail(token: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(token);
}

function isInlineCode(token: string): boolean {
  // Detect backtick-wrapped content
  return token.startsWith('`') && token.endsWith('`') && token.length > 2;
}

// ─── Segment types ────────────────────────────────────────────────────────────

interface Segment {
  display: string;       // verbatim display text of this segment
  speech: string;        // speech text (SSML fragments allowed)
  displayStart: number;  // char offset in full displayText
  displayEnd: number;
}

// ─── Main normalizer ──────────────────────────────────────────────────────────

export function normalize(rawText: string): NormalizerOutput {
  const displayText = rawText; // NEVER modified
  const segments: Segment[] = [];

  const lines = rawText.split('\n');
  let charOffset = 0;

  for (let lineIdx = 0; lineIdx < lines.length; lineIdx++) {
    const line = lines[lineIdx];
    const lineStart = charOffset;

    // ── Blank line → paragraph break ────────────────────────────────────────
    if (line.trim() === '') {
      segments.push({
        display: '',
        speech: '<break time="400ms"/>',
        displayStart: charOffset,
        displayEnd: charOffset,
      });
      charOffset += line.length + 1; // +1 for \n
      continue;
    }

    // ── Heading (Markdown # / ##) ────────────────────────────────────────────
    const headingMatch = line.match(/^(#{1,6})\s+(.*)/);
    if (headingMatch) {
      const headingText = headingMatch[2];
      const headingDisplayStart = charOffset + headingMatch[1].length + 1; // after "## "
      
      // Push a leading break as a virtual segment with no display range
      segments.push({
        display: '',
        speech: '<break time="600ms"/>',
        displayStart: charOffset,
        displayEnd: charOffset,
      });

      // Process the heading body as normal tokens
      processTokens(headingText, headingDisplayStart, segments);
      
      segments.push({
        display: '',
        speech: '<break time="400ms"/>',
        displayStart: charOffset + line.length,
        displayEnd: charOffset + line.length,
      });

      charOffset += line.length + 1;
      continue;
    }

    // ── Bullet point line (•, -, *) ──────────────────────────────────────────
    const bulletMatch = line.match(/^(\s*)(•|-|\*)\s+(.*)/);
    if (bulletMatch) {
      const itemText = bulletMatch[3];
      // Skip the bullet symbol entirely in speech
      const itemDisplayStart = charOffset + bulletMatch[1].length + bulletMatch[2].length + 1;
      processTokens(itemText, itemDisplayStart, segments);
      charOffset += line.length + 1;
      continue;
    }

    // ── Numbered list (e.g. "3. Item text") ─────────────────────────────────
    const numberedMatch = line.match(/^(\s*)(\d+)\.\s+(.*)/);
    if (numberedMatch) {
      const num = numberedMatch[2];
      const itemText = numberedMatch[3];
      const numDisplayStart = charOffset + numberedMatch[1].length;
      const markerDisplayEnd = numDisplayStart + num.length + 1; // "3."
      
      // "3." → <say-as cardinal>3</say-as>, — maps to display range of "3."
      segments.push({
        display: num + '.',
        speech: `<say-as interpret-as="cardinal">${escapeXml(num)}</say-as>,`,
        displayStart: numDisplayStart,
        displayEnd: markerDisplayEnd,
      });

      const itemStart = markerDisplayEnd + 1; // after "3. "
      processTokens(itemText, itemStart, segments);
      charOffset += line.length + 1;
      continue;
    }

    // ── Normal line ──────────────────────────────────────────────────────────
    processTokens(line, charOffset, segments);
    charOffset += line.length + 1;
  }

  // ─── Build SSML and alignment map ─────────────────────────────────────────
  const alignmentMap: AlignmentEntry[] = [];
  let speechIdx = 0;
  const ssmlParts: string[] = ['<speak>'];

  for (const seg of segments) {
    if (!seg.display && seg.speech.startsWith('<break')) {
      // Pure SSML structural tag — not a speakable word; no alignment entry
      ssmlParts.push(seg.speech);
      continue;
    }

    // Tokenize speech text to count how many Polly speech tokens this will produce
    // Polly fires one Speech Mark per whitespace-separated token in the plain text
    // SSML tags are transparent to Polly's word tokenizer
    const speechTokens = speechTokenize(seg.speech);

    ssmlParts.push(seg.speech);

    for (let i = 0; i < speechTokens; i++) {
      alignmentMap.push({
        speechIdx,
        displayStart: seg.displayStart,
        displayEnd: seg.displayEnd,
      });
      speechIdx++;
    }
  }

  ssmlParts.push('</speak>');
  const ssml = ssmlParts.join(' ');

  return { displayText, ssml, alignmentMap };
}

/**
 * Estimate how many word-level Speech Marks Polly will fire for an SSML fragment.
 * SSML tags themselves are not words; only the text content tokens count.
 */
function speechTokenize(speechFragment: string): number {
  // Strip SSML tags to get plain text Polly will tokenize
  const plain = speechFragment
    .replace(/<[^>]+>/g, ' ')   // remove XML tags
    .replace(/\s+/g, ' ')
    .trim();
  if (!plain) return 0;
  return plain.split(' ').filter(t => t.length > 0).length;
}

/**
 * Process a run of normal text token by token, appending Segment objects.
 */
function processTokens(text: string, baseOffset: number, segments: Segment[]): void {
  // Tokenize preserving whitespace offsets
  // Match either a whitespace run or a non-whitespace token
  const tokenRegex = /(\S+|\s+)/g;
  let match: RegExpExecArray | null;
  let localOffset = 0;

  while ((match = tokenRegex.exec(text)) !== null) {
    const token = match[0];
    const tokenStart = baseOffset + localOffset;
    const tokenEnd = tokenStart + token.length;
    localOffset += token.length;

    // Skip whitespace — carry it to SSML as a space but no alignment entry needed
    if (/^\s+$/.test(token)) {
      segments.push({ display: token, speech: ' ', displayStart: tokenStart, displayEnd: tokenEnd });
      continue;
    }

    const seg = normalizeToken(token, tokenStart, tokenEnd);
    segments.push(seg);
  }
}

function normalizeToken(token: string, displayStart: number, displayEnd: number): Segment {
  // ── Inline code ──────────────────────────────────────────────────────────
  if (isInlineCode(token)) {
    const inner = token.slice(1, -1);
    const wordCount = inner.trim().split(/\s+/).length;
    if (wordCount < 8) {
      return { display: token, speech: `the code: ${escapeXml(inner)}`, displayStart, displayEnd };
    } else {
      return { display: token, speech: 'a code example follows, check the screen to view it', displayStart, displayEnd };
    }
  }

  // ── Email ─────────────────────────────────────────────────────────────────
  if (isEmail(token)) {
    return { display: token, speech: 'an email address', displayStart, displayEnd };
  }

  // ── Full URL ─────────────────────────────────────────────────────────────
  if (isFullUrl(token)) {
    return { display: token, speech: 'a web link', displayStart, displayEnd };
  }

  // ── Short domain-only URL ─────────────────────────────────────────────────
  // Detect pattern like "khanacademy.org" as a standalone token
  if (/^[a-zA-Z0-9-]+\.[a-zA-Z]{2,6}$/.test(token) && !token.match(/^\d/)) {
    const domain = token.replace(/^www\./, '');
    return { display: token, speech: escapeXml(domain), displayStart, displayEnd };
  }

  // ── Abbreviations ─────────────────────────────────────────────────────────
  // Try exact match including trailing punctuation
  const abbrevKey = Object.keys(ABBREVIATIONS).find(k => token === k || token === k.replace(/\.$/, ''));
  if (abbrevKey) {
    return { display: token, speech: ABBREVIATIONS[abbrevKey], displayStart, displayEnd };
  }

  // ── Em-dash ───────────────────────────────────────────────────────────────
  if (token === '—') {
    return { display: token, speech: ',', displayStart, displayEnd };
  }

  // ── Ellipsis ─────────────────────────────────────────────────────────────
  if (token === '...' || token === '…') {
    return { display: token, speech: '<break time="300ms"/>', displayStart, displayEnd };
  }

  // ── Ampersand ─────────────────────────────────────────────────────────────
  if (token === '&') {
    return { display: token, speech: 'and', displayStart, displayEnd };
  }

  // ── Number range "10-15" ─────────────────────────────────────────────────
  const rangeMatch = token.match(/^(\d+)-(\d+)(\S*)$/);
  if (rangeMatch) {
    const suffix = rangeMatch[3] ? escapeXml(rangeMatch[3]) : '';
    const speech = `<say-as interpret-as="cardinal">${rangeMatch[1]}</say-as> to <say-as interpret-as="cardinal">${rangeMatch[2]}</say-as>${suffix}`;
    return { display: token, speech, displayStart, displayEnd };
  }

  // ── Slash: word/word or ACRONYM/ACRONYM ──────────────────────────────────
  const slashMatch = token.match(/^([A-Za-z0-9]+)\/([A-Za-z0-9]+)(\W*)$/);
  if (slashMatch) {
    const left = slashMatch[1], right = slashMatch[2], trail = slashMatch[3];
    const spoken = slashRule(left, right);
    return { display: token, speech: escapeXml(spoken) + escapeXml(trail), displayStart, displayEnd };
  }

  // ── Percentage "45%" ─────────────────────────────────────────────────────
  const percentMatch = token.match(/^(\d+(?:\.\d+)?)%(\W*)$/);
  if (percentMatch) {
    const speech = `<say-as interpret-as="cardinal">${percentMatch[1]}</say-as> percent${percentMatch[2] ? escapeXml(percentMatch[2]) : ''}`;
    return { display: token, speech, displayStart, displayEnd };
  }

  // ── Explicit ordinal "1st", "2nd", "3rd", "4th" etc. ────────────────────
  const ordinalMatch = token.match(/^(\d+)(st|nd|rd|th)(\W*)$/i);
  if (ordinalMatch) {
    const speech = `<say-as interpret-as="ordinal">${ordinalMatch[1]}</say-as>${ordinalMatch[3] ? escapeXml(ordinalMatch[3]) : ''}`;
    return { display: token, speech, displayStart, displayEnd };
  }

  // ── Plain number (with optional trailing punctuation) ────────────────────
  const numMatch = token.match(/^(\d+(?:\.\d+)?)(\W*)$/);
  if (numMatch) {
    const speech = `<say-as interpret-as="cardinal">${numMatch[1]}</say-as>${numMatch[2] ? escapeXml(numMatch[2]) : ''}`;
    return { display: token, speech, displayStart, displayEnd };
  }

  // ── Default: pass through (XML-escaped) ──────────────────────────────────
  return { display: token, speech: escapeXml(token), displayStart, displayEnd };
}
