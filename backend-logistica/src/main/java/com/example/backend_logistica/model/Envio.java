package com.example.backend_logistica.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.JoinColumn;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity // Marca la clase como entidad JPA
public class Envio {

    @Id // Marca el campo 'id' como la clave primaria
    private Long id;

    @ManyToOne // Relación con Pedido (muchos envíos pueden tener un único pedido)
    @JoinColumn(name = "pedido_id") // Establece el nombre de la columna para la relación
    private Pedido pedido;

    @ManyToOne // Relación con Conductor (muchos envíos pueden tener un único conductor)
    @JoinColumn(name = "conductor_id") // Establece el nombre de la columna para la relación
    private Conductor conductor;

    @ManyToOne // Relación con Vehiculo (muchos envíos pueden tener un único vehículo)
    @JoinColumn(name = "vehiculo_id") // Establece el nombre de la columna para la relación
    private Vehiculo vehiculo;

    private LocalDateTime fechaEntregaEstimada;
    private LocalDateTime fechaCreacion;
    private LocalDateTime fechaEntregaReal;
    private String estadoEnvio;
    private Double ubicacionOrigenLatitud;
    private Double ubicacionOrigenLongitud;
    private Double ubicacionDestinoLatitud;
    private Double ubicacionDestinoLongitud;
    private String codigoQrEntrega;
    private String firmaDigitalEntrega;
}
