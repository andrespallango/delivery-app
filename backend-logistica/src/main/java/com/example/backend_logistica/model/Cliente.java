package com.example.backend_logistica.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonManagedReference;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "clientes") // Opcional, pero especifica el nombre de la tabla en la base de datos
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // Asegura que el ID se genere automáticamente
    private Long id;

    private String nombre;
    private String direccion;
    private String telefono;
    private String email;

    @OneToMany(mappedBy = "cliente", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference //  👈 ¡Añade esta anotación!
    private List<Pedido> pedidos;
}
