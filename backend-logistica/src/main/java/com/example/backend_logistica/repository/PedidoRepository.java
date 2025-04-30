package com.example.backend_logistica.repository;

import com.example.backend_logistica.model.Pedido;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PedidoRepository extends JpaRepository<Pedido, Long> {
    // Puedes añadir métodos query personalizados si los necesitas en el futuro,
    // por ejemplo, para buscar pedidos por estado, número de pedido, cliente, rango de fechas, etc.
    // List<Pedido> findByEstado(String estado);
    // Pedido findByNumeroPedido(String numeroPedido);
    // List<Pedido> findByClienteId(Long clienteId);
}