package com.example.backend_logistica.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.GeneratedValue; // 👈  IMPORTANTE: ¡Asegúrate de tener este import!
import jakarta.persistence.GenerationType; // 👈  IMPORTANTE: ¡Asegúrate de tener este import!
import jakarta.persistence.Table; // 👈  IMPORTANTE: ¡Asegúrate de tener este import!
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity // Marca la clase como entidad JPA
@Table(name = "vehiculo") //  ✅ ¡Asegúrate de que el nombre de la tabla sea correcto!
public class Vehiculo {

    @Id // Marca el campo 'id' como la clave primaria
    @GeneratedValue(strategy = GenerationType.IDENTITY) //  👈  ¡ANOTACIÓN CRUCIAL! Añade esta línea COMPLETA
    private Long id;

    private String matricula;
    private String tipo;
    private String modelo;
    private String marca;

    @OneToMany(mappedBy = "vehiculo") // Relación con Conductores
    private List<Conductor> conductores;

    @OneToMany(mappedBy = "vehiculo") // Relación con Envio
    private List<Envio> envios;
}