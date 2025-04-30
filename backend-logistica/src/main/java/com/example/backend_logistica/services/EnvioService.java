package com.example.backend_logistica.services;

import com.example.backend_logistica.model.Conductor;
import com.example.backend_logistica.model.Envio;
import com.example.backend_logistica.model.Pedido;
import com.example.backend_logistica.model.Vehiculo;
import com.example.backend_logistica.repository.ConductorRepository;
import com.example.backend_logistica.repository.EnvioRepository;
import com.example.backend_logistica.repository.PedidoRepository;
import com.example.backend_logistica.repository.VehiculoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class EnvioService {

    private final EnvioRepository envioRepository;
    private final PedidoRepository pedidoRepository;
    private final ConductorRepository conductorRepository;
    private final VehiculoRepository vehiculoRepository;
    private final NotificacionService notificacionService; // Inject NotificacionService

    @Autowired
    public EnvioService(EnvioRepository envioRepository, PedidoRepository pedidoRepository, ConductorRepository conductorRepository, VehiculoRepository vehiculoRepository, NotificacionService notificacionService) {
        this.envioRepository = envioRepository;
        this.pedidoRepository = pedidoRepository;
        this.conductorRepository = conductorRepository;
        this.vehiculoRepository = vehiculoRepository;
        this.notificacionService = notificacionService;
    }

    public List<Envio> obtenerTodosEnvios() {
        return envioRepository.findAll();
    }

    public Optional<Envio> obtenerEnvioPorId(Long id) {
        return envioRepository.findById(id);
    }

    public Envio guardarEnvio(Envio envio) {
        // Aquí podrías añadir validaciones de negocio específicas para el Envio antes de guardar
        return envioRepository.save(envio);
    }

    public void eliminarEnvio(Long id) {
        envioRepository.deleteById(id);
    }

    public Envio asignarEnvio(Long pedidoId) {
        Optional<Pedido> pedidoOptional = pedidoRepository.findById(pedidoId);
        if (!pedidoOptional.isPresent()) {
            throw new IllegalArgumentException("Pedido no encontrado con ID: " + pedidoId);
        }
        Pedido pedido = pedidoOptional.get();

        List<Conductor> conductoresDisponibles = conductorRepository.findByDisponibleTrue();
        if (conductoresDisponibles.isEmpty()) {
            throw new IllegalStateException("No hay conductores disponibles para asignar el pedido.");
        }
        Conductor conductorAsignado = conductoresDisponibles.get(0); // Simplemente asignamos el primer conductor disponible

        Envio nuevoEnvio = new Envio();
        nuevoEnvio.setPedido(pedido);
        nuevoEnvio.setConductor(conductorAsignado);
        nuevoEnvio.setVehiculo(conductorAsignado.getVehiculo());
        nuevoEnvio.setEstadoEnvio("Pendiente de Recolección");
        nuevoEnvio.setFechaEntregaEstimada(LocalDateTime.now().plusHours(3));

        conductorAsignado.setDisponible(false);
        conductorRepository.save(conductorAsignado);
        Envio envioGuardado = envioRepository.save(nuevoEnvio);

        // --- Enviar Notificación Push al Conductor ---
        String conductorDeviceToken = "TU_DEVICE_TOKEN_CONDUCTOR"; // **TODO: Obtener el device token del conductor (desde la BD o algún servicio de registro)**
        if (conductorDeviceToken != null && !conductorDeviceToken.isEmpty()) {
            notificacionService.enviarNotificacionPush(conductorDeviceToken,
                    "Nuevo Envío Asignado",
                    "Se te ha asignado el envío para el pedido: " + pedido.getNumeroPedido());
        }
        // --- Fin Notificación ---

        return envioGuardado;
    }

    public Envio registrarEntrega(Long envioId, String codigoQrEntrega, String firmaDigitalEntrega) {
        Optional<Envio> envioOptional = envioRepository.findById(envioId);
        if (!envioOptional.isPresent()) {
            throw new IllegalArgumentException("Envío no encontrado con ID: " + envioId);
        }
        Envio envio = envioOptional.get();

        envio.setEstadoEnvio("Entregado");
        envio.setFechaEntregaReal(LocalDateTime.now());
        envio.setCodigoQrEntrega(codigoQrEntrega);
        envio.setFirmaDigitalEntrega(firmaDigitalEntrega);

        Conductor conductorAsignado = envio.getConductor();
        if (conductorAsignado != null) {
            conductorAsignado.setDisponible(true);
            conductorRepository.save(conductorAsignado);
        }

        Envio envioEntregado = envioRepository.save(envio);

        // --- Enviar Notificación Push al Cliente ---
        String clienteDeviceToken = "TU_DEVICE_TOKEN_CLIENTE"; // **TODO: Obtener el device token del cliente (desde la BD o algún servicio de registro)**
        if (clienteDeviceToken != null && !clienteDeviceToken.isEmpty()) {
            notificacionService.enviarNotificacionPush(clienteDeviceToken,
                    "Envío Entregado",
                    "Tu envío para el pedido " + envio.getPedido().getNumeroPedido() + " ha sido entregado.");
        }
        // --- Fin Notificación ---

        return envioEntregado;
    }

    // --- Historial de Envíos y Reportes ---
    public List<Envio> obtenerHistorialEnviosPorConductor(Long conductorId) {
        return envioRepository.findByConductorId(conductorId);
    }

    public List<Envio> obtenerHistorialEnviosPorCliente(Long clienteId) {
        return envioRepository.findByPedidoClienteId(clienteId);
    }

    public List<Envio> obtenerHistorialEnviosPorRangoFechas(LocalDateTime fechaInicio, LocalDateTime fechaFin) {
        return envioRepository.findByFechaCreacionBetween(fechaInicio, fechaFin);
    }
    // --- Fin Historial y Reportes ---

    public Envio actualizarUbicacionConductor(Long envioId, Double latitud, Double longitud) {
        Optional<Envio> envioOptional = envioRepository.findById(envioId);
        if (!envioOptional.isPresent()) {
            throw new IllegalArgumentException("Envío no encontrado con ID: " + envioId);
        }
        Envio envio = envioOptional.get();
        Conductor conductor = envio.getConductor();

        if (conductor != null) {
            conductor.setUbicacionActualLatitud(latitud);
            conductor.setUbicacionActualLongitud(longitud);
            conductorRepository.save(conductor);
        }
        return envio;
    }
}