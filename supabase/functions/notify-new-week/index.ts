import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import * as admin from "npm:firebase-admin@12.1.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const { courseId, courseTitle, weekTitle, instructorName } = body;

    if (!courseId || !weekTitle) {
      return new Response(JSON.stringify({ error: 'Missing required fields: courseId, weekTitle' }), { 
        status: 400, 
        headers: { ...corsHeaders, "Content-Type": "application/json" } 
      });
    }

    if (!admin.apps.length) {
      const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
      if (!serviceAccountJson) {
        throw new Error('FIREBASE_SERVICE_ACCOUNT environment variable is not set');
      }
      const serviceAccount = JSON.parse(serviceAccountJson);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
      });
    }

    const firestore = admin.firestore();
    const messaging = admin.messaging();

    // 1. Get all enrollments for this course
    const enrollmentsSnapshot = await firestore
      .collection('enrollments')
      .where('courseId', '==', courseId)
      .get();
      
    const studentIds = new Set<string>();
    enrollmentsSnapshot.docs.forEach((doc: any) => {
      const data = doc.data();
      if (data.studentId) studentIds.add(data.studentId);
    });

    if (studentIds.size === 0) {
      return new Response(JSON.stringify({ message: 'No students enrolled in this course.' }), { 
        status: 200, 
        headers: { ...corsHeaders, "Content-Type": "application/json" } 
      });
    }

    // 2. Fetch FCM tokens for these students
    const tokensSnapshot = await firestore.collection('fcmTokens').get();
    const fcmTokens: string[] = [];

    tokensSnapshot.docs.forEach((doc: any) => {
      const data = doc.data();
      if (data.uid && studentIds.has(data.uid) && data.token) {
        fcmTokens.push(data.token);
      }
    });

    const title = courseTitle ? `New Week in ${courseTitle}` : 'New Course Material Available';
    const messageBody = `${instructorName ? instructorName + ' uploaded' : 'A new week:'} ${weekTitle}. Tap to start learning!`;

    // 3. Send FCM push notifications
    let fcmResult = { successCount: 0, failureCount: 0 };
    if (fcmTokens.length > 0) {
      const messagePayload = {
        notification: {
          title: title,
          body: messageBody,
        },
        data: {
          courseId: courseId,
          type: 'new_week'
        },
        tokens: fcmTokens,
      };
      
      messagePayload.tokens = messagePayload.tokens.filter(t => t && t.trim() !== '');
      if (messagePayload.tokens.length > 0) {
        fcmResult = await messaging.sendEachForMulticast(messagePayload);
      }
    }

    // 4. Save to `notifications` collection
    const batch = firestore.batch();
    const nowISO = new Date().toISOString(); 
    
    studentIds.forEach((studentId) => {
      const notifRef = firestore.collection('notifications').doc();
      batch.set(notifRef, {
        recipientId: studentId,
        title: title,
        body: messageBody,
        type: 'ANNOUNCEMENT',
        referenceId: courseId,
        read: false,
        createdAt: nowISO,
      });
    });

    await batch.commit();

    return new Response(JSON.stringify({ 
      success: true, 
      notifiedStudents: studentIds.size,
      pushSent: fcmResult.successCount
    }), { 
      status: 200, 
      headers: { ...corsHeaders, "Content-Type": "application/json" } 
    });

  } catch (error: any) {
    console.error('Error in notify-new-week:', error);
    return new Response(JSON.stringify({ error: error.message }), { 
      status: 500, 
      headers: { ...corsHeaders, "Content-Type": "application/json" } 
    });
  }
});
