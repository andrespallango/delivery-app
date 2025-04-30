package com.example.backend_logistica.controller;

import com.example.backend_logistica.model.Vehiculo;
import com.example.backend_logistica.services.VehiculoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/vehiculos")
public class VehiculoController {

    private final VehiculoService vehiculoService;

    @Autowired
    public VehiculoController(VehiculoService vehiculoService) {
        this.vehiculoService = vehiculoService;
    }

    @GetMapping
    public ResponseEntity<List<Vehiculo>> obtenerTodosVehiculos() {
        return new ResponseEntity<>(vehiculoService.obtenerTodosVehiculos(), HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Vehiculo> obtenerVehiculoPorId(@PathVariable Long id) {
        Optional<Vehiculo> vehiculo = vehiculoService.obtenerVehiculoPorId(id);
        return vehiculo.map(value -> new ResponseEntity<>(value, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @PostMapping
    public ResponseEntity<Vehiculo> crearVehiculo(@RequestBody Vehiculo vehiculo) {
        Vehiculo nuevoVehiculo = vehiculoService.guardarVehiculo(vehiculo);
        return new ResponseEntity<>(nuevoVehiculo, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Vehiculo> actualizarVehiculo(@PathVariable Long id, @RequestBody Vehiculo vehiculoActualizado) {
        Optional<Vehiculo> vehiculoExistente = vehiculoService.obtenerVehiculoPorId(id);
        if (vehiculoExistente.isPresent()) {
            vehiculoActualizado.setId(id);
            Vehiculo vehiculoGuardado = vehiculoService.guardarVehiculo(vehiculoActualizado);
            return new ResponseEntity<>(vehiculoGuardado, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarVehiculo(@PathVariable Long id) {
        vehiculoService.eliminarVehiculo(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}