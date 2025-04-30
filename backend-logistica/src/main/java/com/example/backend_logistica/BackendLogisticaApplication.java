package com.example.backend_logistica;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import java.io.IOException;
import java.io.InputStream;

@SpringBootApplication
public class BackendLogisticaApplication {

	public static void main(String[] args) {
		SpringApplication.run(BackendLogisticaApplication.class, args);
	}

	@Bean // Indica que este método provee un Bean para Spring IoC Container
	public FirebaseApp firebaseApp() throws IOException {
		InputStream serviceAccount = getClass().getClassLoader().getResourceAsStream("serviceAccountKey.json"); // Reemplaza "serviceAccountKey.json" si nombraste tu archivo diferente y si lo pusiste en otra ruta dentro de resources.

		if (serviceAccount == null) {
			throw new IOException("No se pudo encontrar el archivo serviceAccountKey.json en src/main/resources/");
		}

		FirebaseOptions options = FirebaseOptions.builder()
				.setCredentials(GoogleCredentials.fromStream(serviceAccount))
				.build();

		return FirebaseApp.initializeApp(options);
	}

	@Bean // Bean para FirebaseMessaging (para inyectar en tus Services que necesiten enviar notificaciones push)
	public FirebaseMessaging firebaseMessaging(FirebaseApp firebaseApp) {
		return FirebaseMessaging.getInstance(firebaseApp);
	}
}