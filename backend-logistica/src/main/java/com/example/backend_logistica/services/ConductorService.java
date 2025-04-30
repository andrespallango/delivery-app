package com.example.backend_logistica.services;

import com.example.backend_logistica.model.Conductor;
import com.example.backend_logistica.repository.ConductorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ConductorService {

    private final ConductorRepository conductorRepository;

    @Autowired
    public ConductorService(ConductorRepository conductorRepository) {
        this.conductorRepository = conductorRepository;
    }

    public List<Conductor> obtenerTodosConductores() {
        return conductorRepository.findAll();
    }

    public Optional<Conductor> obtenerConductorPorId(Long id) {
        return conductorRepository.findById(id);
    }

    public Conductor guardarConductor(Conductor conductor) {
        // Aquí podrías añadir validaciones de negocio específicas para el Conductor antes de guardar
        return conductorRepository.save(conductor);
    }

    public void eliminarConductor(Long id) {
        conductorRepository.deleteById(id);
    }

    public List<Conductor> obtenerConductoresDisponibles() {
        return conductorRepository.findByDisponibleTrue();
    }

    public Conductor actualizarUbicacionConductor(Long conductorId, Double latitud, Double longitud) {
        Optional<Conductor> conductorOptional = conductorRepository.findById(conductorId);
        if (conductorOptional.isPresent()) {
            Conductor conductor = conductorOptional.get();
            conductor.setUbicacionActualLatitud(latitud);
            conductor.setUbicacionActualLongitud(longitud);
            return conductorRepository.save(conductor);
        } else {
            throw new IllegalArgumentException("Conductor no encontrado con ID: " + conductorId);
        }
    }
}