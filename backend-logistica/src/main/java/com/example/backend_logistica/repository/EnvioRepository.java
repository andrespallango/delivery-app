package com.example.backend_logistica.repository;

import com.example.backend_logistica.model.Envio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface EnvioRepository extends JpaRepository<Envio, Long> {
    List<Envio> findByConductorId(Long conductorId); // Encontrar envíos por ID de conductor
    List<Envio> findByPedidoClienteId(Long clienteId); // Encontrar envíos por ID de cliente (a través del Pedido)

    // Métodos para reportes por rango de fechas (ejemplos, puedes ajustarlos según necesidad):
    List<Envio> findByFechaCreacionBetween(LocalDateTime inicio, LocalDateTime fin);
    List<Envio> findByFechaEntregaRealBetween(LocalDateTime inicio, LocalDateTime fin);

    // Puedes añadir más métodos query personalizados para reportes o búsquedas específicas, como:
    // List<Envio> findByEstadoEnvio(String estadoEnvio); // Buscar por estado de envío
    // List<Envio> findByVehiculoTipo(String tipoVehiculo); // Envíos realizados con cierto tipo de vehículo
}