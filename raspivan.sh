#!/bin/bash

clone_projects() {
    echo "Clonando proyectos desde GitHub (o submódulos)..."
    # Ejemplo: git clone https://github.com/tu_usuario/tu_proyecto.git ~/projects/tu_proyecto
    # O mejor aún, usa submódulos de Git si son proyectos que ya tienes en GitHub
    git submodule update --init --recursive
}

clone_projects
