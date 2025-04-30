package com.example.backend_logistica.repository;

import com.example.backend_logistica.model.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ClienteRepository extends JpaRepository<Cliente, Long> {
    // Puedes añadir métodos query personalizados si los necesitas en el futuro,
    // pero para operaciones CRUD básicas, JpaRepository ya proporciona todo.
}