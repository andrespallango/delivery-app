package com.example.backend_logistica.services;

import com.example.backend_logistica.model.Vehiculo;
import com.example.backend_logistica.repository.VehiculoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class VehiculoService {

    private final VehiculoRepository vehiculoRepository;

    @Autowired
    public VehiculoService(VehiculoRepository vehiculoRepository) {
        this.vehiculoRepository = vehiculoRepository;
    }

    public List<Vehiculo> obtenerTodosVehiculos() {
        return vehiculoRepository.findAll();
    }

    public Optional<Vehiculo> obtenerVehiculoPorId(Long id) {
        return vehiculoRepository.findById(id);
    }

    public Vehiculo guardarVehiculo(Vehiculo vehiculo) {
        // Aquí podrías añadir validaciones de negocio específicas para el Vehiculo antes de guardar
        return vehiculoRepository.save(vehiculo);
    }

    public void eliminarVehiculo(Long id) {
        vehiculoRepository.deleteById(id);
    }
}