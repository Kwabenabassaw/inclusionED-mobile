import os
import re

def remove_const_from_dart_files(directory):
    # This regex looks for the word "const" followed by common Flutter UI elements 
    # that often wrap Text widgets, as well as lists "[".
    # Removing these will allow the Text widgets to rebuild dynamically.
    # We can rely on `dart fix --apply` later to add back `const` where it is actually safe.
    pattern = re.compile(r'\bconst\s+(Text|\[|Padding|Center|Column|Row|SizedBox|Align|Expanded|Flexible|Container|RichText|Icon|ListTile|Card|Drawer|AppBar|Scaffold|Tab|TabBar)\b')
    
    updated_files = 0

    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    # Perform the replacement
                    new_content = pattern.sub(r'\1', content)
                    
                    # We should also replace `const ` when it precedes a custom widget, but regex is tricky there.
                    # Let's add another pass for `const TextSpan` and `const EdgeInsets` just in case, though EdgeInsets is fine to keep const.
                    
                    if new_content != content:
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        print(f"Removed consts from: {filepath}")
                        updated_files += 1
                except Exception as e:
                    print(f"Could not process {filepath}: {e}")
                    
    print(f"\nDone! Updated {updated_files} files.")
    print("Recommendation: Run `dart fix --apply` after this to automatically restore `const` to widgets that don't contain Text.")

if __name__ == "__main__":
    # Point this to your lib directory
    lib_dir = os.path.join(os.path.dirname(__file__), 'lib')
    remove_const_from_dart_files(lib_dir)
