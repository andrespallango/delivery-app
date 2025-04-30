package com.example.backend_logistica.controller;

import com.example.backend_logistica.model.Conductor;
import com.example.backend_logistica.services.ConductorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/conductores")
public class ConductorController {

    private final ConductorService conductorService;

    @Autowired
    public ConductorController(ConductorService conductorService) {
        this.conductorService = conductorService;
    }

    @GetMapping
    public ResponseEntity<List<Conductor>> obtenerTodosConductores() {
        return new ResponseEntity<>(conductorService.obtenerTodosConductores(), HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Conductor> obtenerConductorPorId(@PathVariable Long id) {
        Optional<Conductor> conductor = conductorService.obtenerConductorPorId(id);
        return conductor.map(value -> new ResponseEntity<>(value, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @PostMapping
    public ResponseEntity<Conductor> crearConductor(@RequestBody Conductor conductor) {
        Conductor nuevoConductor = conductorService.guardarConductor(conductor);
        return new ResponseEntity<>(nuevoConductor, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Conductor> actualizarConductor(@PathVariable Long id, @RequestBody Conductor conductorActualizado) {
        Optional<Conductor> conductorExistente = conductorService.obtenerConductorPorId(id);
        if (conductorExistente.isPresent()) {
            conductorActualizado.setId(id);
            Conductor conductorGuardado = conductorService.guardarConductor(conductorActualizado);
            return new ResponseEntity<>(conductorGuardado, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarConductor(@PathVariable Long id) {
        conductorService.eliminarConductor(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @GetMapping("/disponibles")
    public ResponseEntity<List<Conductor>> obtenerConductoresDisponibles() {
        return new ResponseEntity<>(conductorService.obtenerConductoresDisponibles(), HttpStatus.OK);
    }

    @PostMapping("/{id}/ubicacion") // Endpoint para actualizar la ubicación del conductor directamente
    public ResponseEntity<Conductor> actualizarUbicacionConductor(
            @PathVariable Long id,
            @RequestParam Double latitud,
            @RequestParam Double longitud) {
        try {
            Conductor conductorActualizado = conductorService.actualizarUbicacionConductor(id, latitud, longitud);
            return new ResponseEntity<>(conductorActualizado, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
}