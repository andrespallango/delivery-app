package com.example.backend_logistica.repository;

import com.example.backend_logistica.model.Vehiculo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VehiculoRepository extends JpaRepository<Vehiculo, Long> {
    // Puedes añadir métodos query personalizados si los necesitas en el futuro,
    // por ejemplo, para buscar vehículos por tipo, marca, modelo, etc.
    // List<Vehiculo> findByTipo(String tipo);
    // List<Vehiculo> findByMarcaIgnoreCase(String marca);
}