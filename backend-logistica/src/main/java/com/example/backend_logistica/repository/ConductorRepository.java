package com.example.backend_logistica.repository;

import com.example.backend_logistica.model.Conductor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ConductorRepository extends JpaRepository<Conductor, Long> {
    List<Conductor> findByDisponibleTrue(); // Método para encontrar conductores disponibles (disponible = true)

    // Puedes añadir métodos query personalizados adicionales, por ejemplo:
    // List<Conductor> findByVehiculoTipo(String tipoVehiculo);
    // List<Conductor> findByNombreContainingIgnoreCase(String nombre);
}