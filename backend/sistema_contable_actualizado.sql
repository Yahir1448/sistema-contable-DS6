-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS sistema_contable
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sistema_contable;

-- Desactivar claves foráneas temporalmente
SET FOREIGN_KEY_CHECKS = 0;

-- Eliminar tablas existentes si existen
DROP TABLE IF EXISTS 
  respaldo_datos,
  configuraciones_usuario,
  reportes_generados,
  presupuestos,
  transacciones,
  cuentas,
  metas_ahorro,
  gastos,
  ingresos,
  categorias,
  usuarios;

-- Reactivar claves foráneas
SET FOREIGN_KEY_CHECKS = 1;

-- Crear tabla usuarios
CREATE TABLE usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
  correo VARCHAR(100) NOT NULL UNIQUE,
  contraseña_hash VARCHAR(255) NOT NULL,
  nombre VARCHAR(50),
  apellido VARCHAR(50),
  moneda VARCHAR(10) NOT NULL DEFAULT 'USD',
  idioma VARCHAR(10) NOT NULL DEFAULT 'es',
  fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  esta_activo TINYINT NOT NULL DEFAULT 1
) ENGINE=InnoDB;

-- Crear tabla categorias
CREATE TABLE categorias (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  tipo ENUM('ingreso', 'gasto') NOT NULL
) ENGINE=InnoDB;

-- Crear tabla ingresos
CREATE TABLE ingresos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  monto DECIMAL(10, 2) NOT NULL,
  categoria_id INT NOT NULL,
  fecha DATETIME NOT NULL,
  descripcion VARCHAR(255),
  usuario_id INT NOT NULL,
  es_recurrente TINYINT NOT NULL DEFAULT 0,
  periodo VARCHAR(20),
  FOREIGN KEY (categoria_id) REFERENCES categorias(id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- Crear tabla gastos
CREATE TABLE gastos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  monto DECIMAL(10, 2) NOT NULL,
  categoria_id INT NOT NULL,
  fecha DATETIME NOT NULL,
  descripcion VARCHAR(255),
  usuario_id INT NOT NULL,
  FOREIGN KEY (categoria_id) REFERENCES categorias(id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- Crear tabla metas de ahorro
CREATE TABLE metas_ahorro (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  monto DECIMAL(10, 2) NOT NULL,
  categoria_id INT,
  fecha_inicio DATETIME NOT NULL,
  fecha_fin DATETIME NOT NULL,
  alcanzado TINYINT NOT NULL DEFAULT 0,
  descripcion VARCHAR(255),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
  FOREIGN KEY (categoria_id) REFERENCES categorias(id)
) ENGINE=InnoDB;

-- Crear tabla cuentas
CREATE TABLE cuentas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  tipo ENUM('efectivo', 'banco', 'tarjeta_credito', 'tarjeta_debito') NOT NULL,
  saldo_actual DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  saldo_objetivo DECIMAL(10,2) DEFAULT NULL,
  fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Crear tabla transacciones
CREATE TABLE transacciones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  tipo ENUM('ingreso', 'gasto', 'transferencia') NOT NULL,
  importe DECIMAL(10,2) NOT NULL,
  fecha DATETIME NOT NULL,
  categoria_id INT,
  cuenta_id INT,
  nota TEXT,
  repetir_cada VARCHAR(100),
  descripcion TEXT,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
  FOREIGN KEY (categoria_id) REFERENCES categorias(id),
  FOREIGN KEY (cuenta_id) REFERENCES cuentas(id)
);

-- Crear tabla presupuestos
CREATE TABLE presupuestos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  mes INT NOT NULL,
  anio INT NOT NULL,
  monto_asignado DECIMAL(10,2) NOT NULL,
  monto_gastado DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Crear tabla reportes generados
CREATE TABLE reportes_generados (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  tipo_reporte VARCHAR(100) NOT NULL,
  fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  url_archivo TEXT,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Crear tabla configuraciones de usuario
CREATE TABLE configuraciones_usuario (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  idioma VARCHAR(20) DEFAULT 'es',
  notificaciones BOOLEAN DEFAULT TRUE,
  tema ENUM('claro', 'oscuro') DEFAULT 'claro',
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Crear tabla respaldo de datos
CREATE TABLE respaldo_datos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  fecha_respaldo DATETIME DEFAULT CURRENT_TIMESTAMP,
  tipo ENUM('manual', 'automático') DEFAULT 'manual',
  archivo_url TEXT,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);
