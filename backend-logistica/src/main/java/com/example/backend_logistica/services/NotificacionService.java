package com.example.backend_logistica.services;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class NotificacionService {

    private static final Logger logger = LoggerFactory.getLogger(NotificacionService.class);

    private final FirebaseMessaging firebaseMessaging;

    public NotificacionService(FirebaseMessaging firebaseMessaging) {
        this.firebaseMessaging = firebaseMessaging;
    }

    public void enviarNotificacionPush(String deviceToken, String titulo, String cuerpo) {
        Notification notification = Notification.builder()
                .setTitle(titulo)
                .setBody(cuerpo)
                .build();

        Message message = Message.builder()
                .setToken(deviceToken) // Token del dispositivo al que enviar la notificación
                .setNotification(notification)
                .build();

        try {
            String response = firebaseMessaging.send(message);
            logger.info("Notificación push enviada exitosamente. Firebase response: {}", response);
        } catch (FirebaseMessagingException e) {
            logger.error("Error al enviar la notificación push: ", e);
            // Aquí podrías implementar lógica de reintento o manejo de errores más robusto
        }
    }
}