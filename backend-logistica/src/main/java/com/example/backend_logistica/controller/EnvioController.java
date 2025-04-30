package com.example.backend_logistica.controller;

import com.example.backend_logistica.model.Envio;
import com.example.backend_logistica.services.EnvioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/envios")
public class EnvioController {

    private final EnvioService envioService;

    @Autowired
    public EnvioController(EnvioService envioService) {
        this.envioService = envioService;
    }

    @GetMapping
    public ResponseEntity<List<Envio>> obtenerTodosEnvios() {
        return new ResponseEntity<>(envioService.obtenerTodosEnvios(), HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Envio> obtenerEnvioPorId(@PathVariable Long id) {
        Optional<Envio> envio = envioService.obtenerEnvioPorId(id);
        return envio.map(value -> new ResponseEntity<>(value, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @PostMapping
    public ResponseEntity<Envio> crearEnvio(@RequestBody Envio envio) {
        return new ResponseEntity<>(envioService.guardarEnvio(envio), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Envio> actualizarEnvio(@PathVariable Long id, @RequestBody Envio envioActualizado) {
        Optional<Envio> envioExistente = envioService.obtenerEnvioPorId(id);
        if (envioExistente.isPresent()) {
            envioActualizado.setId(id);
            return new ResponseEntity<>(envioService.guardarEnvio(envioActualizado), HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarEnvio(@PathVariable Long id) {
        envioService.eliminarEnvio(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @PostMapping("/asignar/{pedidoId}")
    public ResponseEntity<Envio> asignarEnvio(@PathVariable Long pedidoId) {
        try {
            Envio envioAsignado = envioService.asignarEnvio(pedidoId);
            return new ResponseEntity<>(envioAsignado, HttpStatus.CREATED);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        } catch (IllegalStateException e) {
            return new ResponseEntity<>(HttpStatus.CONFLICT);
        }
    }

    @PostMapping("/registrar-entrega/{envioId}")
    public ResponseEntity<Envio> registrarEntrega(
            @PathVariable Long envioId,
            @RequestParam(value = "codigoQrEntrega", required = false) String codigoQrEntrega,
            @RequestParam(value = "firmaDigitalEntrega", required = false) String firmaDigitalEntrega) {
        try {
            Envio envioEntregado = envioService.registrarEntrega(envioId, codigoQrEntrega, firmaDigitalEntrega);
            return new ResponseEntity<>(envioEntregado, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/historial/conductor/{conductorId}")
    public ResponseEntity<List<Envio>> obtenerHistorialEnviosPorConductor(@PathVariable Long conductorId) {
        return new ResponseEntity<>(envioService.obtenerHistorialEnviosPorConductor(conductorId), HttpStatus.OK);
    }

    @GetMapping("/historial/cliente/{clienteId}")
    public ResponseEntity<List<Envio>> obtenerHistorialEnviosPorCliente(@PathVariable Long clienteId) {
        return new ResponseEntity<>(envioService.obtenerHistorialEnviosPorCliente(clienteId), HttpStatus.OK);
    }

    @GetMapping("/historial/fechas")
    public ResponseEntity<List<Envio>> obtenerHistorialEnviosPorRangoFechas(
            @RequestParam("inicio") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime inicio,
            @RequestParam("fin") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fin) {
        return new ResponseEntity<>(envioService.obtenerHistorialEnviosPorRangoFechas(inicio, fin), HttpStatus.OK);
    }

    @PostMapping("/{envioId}/ubicacion") // Endpoint para actualizar la ubicación del conductor asociado a un envío
    public ResponseEntity<Envio> actualizarUbicacionEnvio( // Renombrado para evitar confusión con ConductorController
                                                           @PathVariable Long envioId,
                                                           @RequestParam Double latitud,
                                                           @RequestParam Double longitud) {
        try {
            Envio envioActualizado = envioService.actualizarUbicacionConductor(envioId, latitud, longitud);
            return new ResponseEntity<>(envioActualizado, HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
}