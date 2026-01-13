DROP DATABASE IF EXISTS Akira;
CREATE DATABASE Akira;
USE Akira;

-- =========================
-- TABLAS PRINCIPALES - EXACTAS A LAS ENTIDADES JAVA
-- =========================

-- Tabla Roles (para sistema Usuario)
CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    INDEX idx_nombre (nombre),
    INDEX idx_activo (activo)
);

-- Tabla Usuarios (empleados del sistema - entidad Usuario.java)
CREATE TABLE usuarios (
    id VARCHAR(8) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(150),
    celular VARCHAR(15),
    direccion VARCHAR(255),
    usuario VARCHAR(50) UNIQUE,
    password VARCHAR(255),
    rol_id INT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_ultimo_acceso DATETIME NULL,
    FOREIGN KEY (rol_id) REFERENCES roles(id),
    INDEX idx_usuario (usuario),
    INDEX idx_correo (correo),
    INDEX idx_celular (celular),
    INDEX idx_rol (rol_id),
    INDEX idx_activo (activo),
    INDEX idx_nombre_apellido (nombre, apellido)
);

-- Tabla Cliente (entidad Cliente.java - EXACTA)
CREATE TABLE cliente (
    dni VARCHAR(20) PRIMARY KEY COMMENT 'DNI (8 dígitos) o RUC (11 dígitos)',
    nombre VARCHAR(100) NOT NULL COMMENT 'Nombre del cliente o representante legal',
    apellido VARCHAR(100) NOT NULL COMMENT 'Apellido o Razón Social (para RUC)',
    correo VARCHAR(100) COMMENT 'Correo electrónico del cliente',
    celular VARCHAR(15) COMMENT 'Número de celular de contacto',
    direccion TEXT COMMENT 'Dirección del cliente',
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    usuario VARCHAR(50) UNIQUE COMMENT 'Usuario para login de clientes',
    password VARCHAR(255) COMMENT 'Contraseña para autenticación de clientes'
);

-- Tabla Marca (entidad Marca.java)
CREATE TABLE marca (
    id_marca INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- Tabla Categoría Producto (entidad Categoria.java)
CREATE TABLE categoria_producto (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    estante VARCHAR(20)
);

-- Tabla Producto (entidad Producto.java - SIN campo activo porque NO está en la entidad)
CREATE TABLE producto (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    cantidad_stock INT DEFAULT 0,
    id_categoria INT,
    id_marca INT,
    modelo VARCHAR(100),
    FOREIGN KEY (id_categoria) REFERENCES categoria_producto(id_categoria),
    FOREIGN KEY (id_marca) REFERENCES marca(id_marca)
);

-- Tabla Estado (entidad Estado.java)
CREATE TABLE estado (
    id_estado INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50) NOT NULL UNIQUE
);

-- Tabla Orden de Pedido (entidad OrdenPedido.java - EXACTA)
CREATE TABLE orden_pedido (
    id_orden INT PRIMARY KEY AUTO_INCREMENT,
    
    -- Claves foráneas EXACTAS a los @JoinColumn
    cliente_dni VARCHAR(20) NOT NULL,
    tecnico_asignado_id VARCHAR(8),
    vendedor_asignado_id VARCHAR(8),
    
    -- Campos de fecha y valores EXACTOS
    fecha_orden DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL,
    
    -- Estado del pedido EXACTO
    id_estado INT NOT NULL DEFAULT 1,
    
    -- Campos adicionales EXACTOS
    observaciones TEXT,
    tipo_pedido VARCHAR(20) NOT NULL DEFAULT 'PRODUCTO_COMPLETO',
    detalles_componentes TEXT,
    
    -- Fechas de seguimiento EXACTAS
    fecha_asignacion DATETIME,
    fecha_atencion DATETIME,
    fecha_cierre DATETIME,
    
    -- Claves foráneas EXACTAS
    FOREIGN KEY (cliente_dni) REFERENCES cliente(dni),
    FOREIGN KEY (tecnico_asignado_id) REFERENCES usuarios(id),
    FOREIGN KEY (vendedor_asignado_id) REFERENCES usuarios(id),
    FOREIGN KEY (id_estado) REFERENCES estado(id_estado)
);

-- Tabla Detalle de Pedido (entidad DetallePedido.java - SIN precio_unitario y subtotal porque NO están en la entidad)
CREATE TABLE detalle_pedido (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_orden INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_orden) REFERENCES orden_pedido(id_orden) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

-- Tabla Banco (entidad Banco.java)
CREATE TABLE banco (
    id_banco INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Registro de Pago (entidad RegistroPago.java - NOMBRE CORRECTO)
CREATE TABLE registroPago (
    id_pago INT PRIMARY KEY AUTO_INCREMENT,
    id_orden INT NOT NULL,
    nro_operacion VARCHAR(50) UNIQUE,
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_banco INT NOT NULL,
    id_estado INT NOT NULL,
    FOREIGN KEY (id_orden) REFERENCES orden_pedido(id_orden),
    FOREIGN KEY (id_banco) REFERENCES banco(id_banco),
    FOREIGN KEY (id_estado) REFERENCES estado(id_estado)
);

-- =========================
-- INSERCIÓN DE DATOS INICIALES
-- =========================

-- Insertar Roles
INSERT INTO roles (nombre, descripcion, activo) VALUES 
('DUEÑO', 'Administrador general del sistema', TRUE),
('VENDEDOR', 'Encargado de ventas y atención al cliente', TRUE),
('TECNICO', 'Técnico especializado en ensamblaje y reparación', TRUE),
('CLIENTE', 'Cliente del sistema', TRUE);

INSERT INTO estado (descripcion) VALUES 
('ASIGNADO'),
('PENDIENTE'),
('ATENDIDO'),
('CERRADO')
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);

-- Insertar Bancos
INSERT INTO banco (nombre) VALUES
('Banco de Crédito del Perú'),
('BBVA');

-- Insertar Usuarios (Empleados del Sistema)
INSERT INTO usuarios (id, nombre, apellido, correo, celular, usuario, password, rol_id, activo, fecha_registro) VALUES
('12345678', 'Carlos', 'Mendoza', 'carlos.mendoza@akira.com', '987654321', 'admin', 'admin', 1, TRUE, CURRENT_TIMESTAMP),
('87654321', 'Ana', 'García', 'ana.garcia@akira.com', '987654322', 'agarcia', '123456789', 2, TRUE, CURRENT_TIMESTAMP),
('11223344', 'Luis', 'Rodríguez', 'luis.rodriguez@akira.com', '987654323', 'lrodriguez', '123456789', 2, TRUE, CURRENT_TIMESTAMP),
('44332211', 'María', 'López', 'maria.lopez@akira.com', '987654324', 'mlopez', '123456789', 3, TRUE, CURRENT_TIMESTAMP),
('55667788', 'Pedro', 'Martínez', 'pedro.martinez@akira.com', '987654325', 'pmartinez', '123456789', 3, TRUE, CURRENT_TIMESTAMP);



-- Insertar Clientes de Ejemplo
INSERT INTO cliente (dni, nombre, apellido, correo, celular, direccion, fecha_registro, activo, usuario) VALUES
('20456789', 'Juan', 'Pérez', 'juan.perez@email.com', '999888777', 'Av. Larco 123, Miraflores', NOW(), TRUE, 'jperez'),
('30567890', 'María', 'González', 'maria.gonzalez@email.com', '999888778', 'Jr. Ucayali 456, Lima', NOW(), TRUE, 'mgonzalez'),
('40678901', 'Carlos', 'Ramírez', 'carlos.ramirez@email.com', '999888779', 'Av. Brasil 789, Breña', NOW(), TRUE, 'cramirez'),
('50789012', 'Ana', 'Torres', 'ana.torres@email.com', '999888780', 'Calle Los Olivos 321, San Isidro', NOW(), TRUE, 'atorres'),
('60890123', 'Roberto', 'Silva', 'roberto.silva@email.com', '999888781', 'Av. Salaverry 654, Jesús María', NOW(), TRUE, 'rsilva');

-- Insertar Marcas
INSERT INTO marca (nombre) VALUES
('ASUS'),('HP'),('Dell'),('Logitech'),('AMD'),('Intel'),('NVIDIA'),('Gigabyte'),('MSI'),('Corsair'),('Razer'),('Cooler Master'),('Kingston'),('Seagate'),('Western Digital'),
('Samsung'),('EVGA'),('NZXT'),('AOC'),('Thermaltake'),('HyperX'),('Lenovo'),('Adata'),('Crucial'),('Noctua'),('Be Quiet!'),('ASRock'),('Zotac'),('BenQ'),('SteelSeries');


-- Insertar Categorías
INSERT INTO categoria_producto (nombre, descripcion, estante) VALUES
('Procesadores', 'CPUs modernos', 'E1'),
('Placa Madre', 'Motherboards compatibles', 'E2'),
('Memoria RAM', 'RAM DDR4 o DDR5', 'E3'),
('Tarjeta Gráfica', 'GPUs dedicadas', 'E4'),
('Unidad M.2', 'Almacenamiento rápido', 'E5'),
('Unidad SSD', 'Discos sólidos', 'E6'),
('Gabinete', 'Cajas para PC', 'B1'),
('Fuente de Poder', 'PSUs variadas', 'B2'),
('Ventilador', 'Fans para flujo de aire', 'B3'),
('Refrigeración CPU', 'Coolers para CPU', 'B4'),
('Pasta Térmica', 'Compuesto térmico', 'B5'),
('Sistema Operativo', 'Software de sistema', 'C1'),
('Antivirus', 'Protección digital', 'C2'),
('Monitor', 'Pantallas LED', 'C3'),
('Mouse', 'Ratones ópticos', 'D1'),
('Teclado', 'Keyboards variados', 'D2'),
('Audífonos', 'Headsets', 'D3'),
('Silla', 'Sillas ergonómicas', 'F1'),
('Escritorio', 'Mesas de trabajo', 'F2'),
('Volante', 'Controles para juegos', 'F3');

-- OPCIÓN 2: Usar la clave primaria (id_categoria)
-- Primero crear la columna
ALTER TABLE categoria_producto ADD COLUMN imagen_url VARCHAR(255);

-- Ver los IDs de las categorías
SELECT id_categoria, nombre FROM categoria_producto ORDER BY id_categoria;

-- Actualizar usando el ID (reemplaza los números con los IDs reales de tu tabla)
UPDATE categoria_producto SET imagen_url = '/images/01.jpg' WHERE id_categoria = 1;  -- Procesadores
UPDATE categoria_producto SET imagen_url = '/images/02.jpg' WHERE id_categoria = 2;  -- Placa Madre
UPDATE categoria_producto SET imagen_url = '/images/03.jpg' WHERE id_categoria = 3;  -- Memoria RAM
UPDATE categoria_producto SET imagen_url = '/images/04.jpg' WHERE id_categoria = 4;  -- Tarjeta Gráfica
UPDATE categoria_producto SET imagen_url = '/images/05.jpg' WHERE id_categoria = 5;  -- Unidad M.2
UPDATE categoria_producto SET imagen_url = '/images/06.jpg' WHERE id_categoria = 6;  -- Unidad SSD
UPDATE categoria_producto SET imagen_url = '/images/07.jpg' WHERE id_categoria = 7;  -- Gabinete
UPDATE categoria_producto SET imagen_url = '/images/08.jpg' WHERE id_categoria = 8;  -- Fuente de Poder
UPDATE categoria_producto SET imagen_url = '/images/09.jpg' WHERE id_categoria = 9;  -- Ventilador
UPDATE categoria_producto SET imagen_url = '/images/10.jpg' WHERE id_categoria = 10; -- Refrigeración CPU
UPDATE categoria_producto SET imagen_url = '/images/11.jpg' WHERE id_categoria = 11; -- Pasta Térmica
UPDATE categoria_producto SET imagen_url = '/images/12.jpg' WHERE id_categoria = 12; -- Sistema Operativo
UPDATE categoria_producto SET imagen_url = '/images/13.jpg' WHERE id_categoria = 13; -- Antivirus
UPDATE categoria_producto SET imagen_url = '/images/14.jpg' WHERE id_categoria = 14; -- Monitor
UPDATE categoria_producto SET imagen_url = '/images/15.jpg' WHERE id_categoria = 15; -- Mouse
UPDATE categoria_producto SET imagen_url = '/images/16.jpg' WHERE id_categoria = 16; -- Teclado
UPDATE categoria_producto SET imagen_url = '/images/17.jpg' WHERE id_categoria = 17; -- Audífonos
UPDATE categoria_producto SET imagen_url = '/images/18.jpg' WHERE id_categoria = 18; -- Silla
UPDATE categoria_producto SET imagen_url = '/images/19.jpg' WHERE id_categoria = 19; -- Escritorio
UPDATE categoria_producto SET imagen_url = '/images/20.jpg' WHERE id_categoria = 20; -- Volante

-- Verificar resultados
SELECT id_categoria, nombre, imagen_url FROM categoria_producto ORDER BY id_categoria;

-- Productos (200 productos)
INSERT INTO producto (id_producto, nombre, descripcion, precio, cantidad_stock, id_categoria, id_marca, modelo) VALUES
/*procesadores*/
(1, 'AMD Ryzen 5 5600X', 'Procesador 6 núcleos, 12 hilos, 4.6GHz', 650.00, 35, 1, 5, 'R5-5600X'),
(2, 'Intel Core i5-12400F', 'Procesador 6 núcleos, 12 hilos, 4.4GHz', 720.00, 28, 1, 6, 'I5-12400F'),
(3, 'AMD Ryzen 7 5800X', 'Procesador 8 núcleos, 16 hilos, 4.7GHz', 950.00, 18, 1, 5, 'R7-5800X'),
(4, 'Intel Core i7-12700K', 'Procesador 12 núcleos, 20 hilos, 5.0GHz', 1200.00, 22, 1, 6, 'I7-12700K'),
(5, 'AMD Ryzen 9 5900X', 'Procesador 12 núcleos, 24 hilos, 4.8GHz', 1400.00, 14, 1, 5, 'R9-5900X'),
(6, 'Intel Core i9-12900K', 'Procesador 16 núcleos, 24 hilos, 5.2GHz', 1850.00, 9, 1, 6, 'I9-12900K'),
(7, 'AMD Ryzen 5 7600X', 'Procesador 6 núcleos, 12 hilos, 5.3GHz', 780.00, 31, 1, 5, 'R5-7600X'),
(8, 'Intel Core i5-13600K', 'Procesador 14 núcleos, 20 hilos, 5.1GHz', 950.00, 27, 1, 6, 'I5-13600K'),
(9, 'AMD Ryzen 7 7700X', 'Procesador 8 núcleos, 16 hilos, 5.4GHz', 1100.00, 11, 1, 5, 'R7-7700X'),
(10, 'Intel Core i9-13900K', 'Procesador 24 núcleos, 32 hilos, 5.8GHz', 2150.00, 8, 1, 6, 'I9-13900K'),
/*placamadre*/
(11, 'ASUS ROG Strix B550-F', 'ATX, soporte Ryzen, DDR4', 650.00, 15, 2, 1, 'B550-F'),
(12, 'MSI B550M PRO-VDH', 'Micro ATX, soporte Ryzen, DDR4', 520.00, 18, 2, 10, 'B550M-PRO'),
(13, 'Gigabyte Z690 AORUS Elite AX', 'ATX, soporte Intel 12th Gen', 890.00, 12, 2, 8, 'Z690-AORUS'),
(14, 'ASRock B450M Steel Legend', 'Micro ATX, soporte Ryzen', 580.00, 20, 2, 26, 'B450M-SL'),
(15, 'ASUS TUF Gaming B660M', 'Soporte Intel 12th Gen', 630.00, 14, 2, 1, 'B660M-TUF'),
(16, 'MSI MAG B550 Tomahawk', 'ATX, soporte Ryzen', 740.00, 16, 2, 10, 'B550-TOMAHAWK'),
(17, 'Gigabyte B550M DS3H', 'Micro ATX, DDR4, Ryzen', 490.00, 22, 2, 8, 'B550M-DS3H'),
(18, 'ASRock Z690 Phantom Gaming', 'ATX, soporte Intel', 910.00, 10, 2, 26, 'Z690-PG'),
(19, 'ASUS Prime B460M-A', 'Intel 10th Gen, Micro ATX', 510.00, 17, 2, 1, 'B460M-A'),
(20, 'Gigabyte X570 AORUS Elite', 'Ryzen, ATX, DDR4', 990.00, 9, 2, 8, 'X570-AORUS'),
/*memoraram*/
(21, 'Corsair Vengeance LPX 16GB', 'DDR4 3200MHz CL16', 280.00, 20, 3, 10, 'CMK16GX4M2B3200C16'),
(22, 'Kingston Fury Beast 16GB', 'DDR4 3200MHz CL16', 275.00, 25, 3, 13, 'KF432C16BBK2'),
(23, 'G.Skill Ripjaws V 16GB', 'DDR4 3600MHz CL18', 290.00, 18, 3, 5, 'F4-3600C18D-16GVK'),
(24, 'TeamGroup T-Force Vulcan Z 16GB', 'DDR4 3200MHz', 260.00, 22, 3, 25, 'TLZGD416G3200HC16CDC01'),
(25, 'ADATA XPG Gammix D30 16GB', 'DDR4 3200MHz', 265.00, 16, 3, 23, 'AX4U320016G16A-SR30'),
(26, 'Crucial Ballistix 16GB', 'DDR4 3200MHz CL16', 270.00, 14, 3, 24, 'BL16G32C16U4B'),
(27, 'Patriot Viper Steel 16GB', 'DDR4 3200MHz', 255.00, 19, 3, 27, 'PVS416G320C6'),
(28, 'Corsair Vengeance RGB Pro 16GB', 'DDR4 3600MHz', 310.00, 21, 3, 10, 'CMW16GX4M2C3600C18'),
(29, 'Kingston Fury Renegade 32GB', 'DDR4 3600MHz', 520.00, 12, 3, 13, 'KF436C16RB1K2/32'),
(30, 'G.Skill Trident Z RGB 32GB', 'DDR4 3600MHz', 550.00, 10, 3, 5, 'F4-3600C18D-32GTZR'),
/*unidad m.2*/
(31, 'Samsung 970 EVO Plus 1TB', 'NVMe M.2 PCIe Gen3 x4', 420.00, 20, 6, 16, 'MZ-V7S1T0B/AM'),
(32, 'Western Digital SN570 1TB', 'NVMe M.2 PCIe Gen3 x4', 400.00, 22, 6, 15, 'WDS100T3B0C'),
(33, 'Crucial MX500 1TB', 'SATA 2.5" SSD', 390.00, 18, 6, 24, 'CT1000MX500SSD1'),
(34, 'Kingston A2000 1TB', 'NVMe M.2 PCIe Gen3 x4', 385.00, 17, 6, 13, 'SA2000M8/1000G'),
(35, 'ADATA XPG SX8200 Pro 1TB', 'NVMe M.2 PCIe Gen3 x4', 405.00, 15, 6, 23, 'ASX8200PNP-1TT-C'),
(36, 'Seagate Barracuda 1TB', 'SATA 2.5" SSD', 375.00, 19, 6, 14, 'ZA1000CM10002'),
(37, 'Patriot P300 1TB', 'NVMe M.2 PCIe Gen3 x4', 360.00, 20, 6, 27, 'P300P1TBM28'),
(38, 'Samsung 870 QVO 1TB', 'SATA 2.5" SSD', 395.00, 16, 6, 16, 'MZ-77Q1T0B'),
(39, 'TeamGroup MP33 1TB', 'NVMe M.2 PCIe Gen3', 350.00, 18, 6, 25, 'TM8FP651T0C101'),
(40, 'Kingston KC2500 1TB', 'NVMe M.2 PCIe Gen3 x4', 410.00, 14, 6, 13, 'SKC2500M8/1000G'),
/*tarjetavideo*/
(41, 'NVIDIA GeForce RTX 3060', '12GB GDDR6', 1600.00, 15, 4, 7, 'RTX3060'),
(42, 'AMD Radeon RX 6600 XT', '8GB GDDR6', 1400.00, 18, 4, 5, 'RX6600XT'),
(43, 'NVIDIA GeForce RTX 3070', '8GB GDDR6', 1900.00, 12, 4, 7, 'RTX3070'),
(44, 'AMD Radeon RX 6700 XT', '12GB GDDR6', 1850.00, 14, 4, 5, 'RX6700XT'),
(45, 'NVIDIA GeForce RTX 3080', '10GB GDDR6X', 2500.00, 10, 4, 7, 'RTX3080'),
(46, 'AMD Radeon RX 6800', '16GB GDDR6', 2400.00, 8, 4, 5, 'RX6800'),
(47, 'NVIDIA GeForce RTX 4060 Ti', '8GB GDDR6', 2000.00, 11, 4, 7, 'RTX4060Ti'),
(48, 'AMD Radeon RX 7600', '8GB GDDR6', 1700.00, 16, 4, 5, 'RX7600'),
(49, 'NVIDIA GeForce RTX 4090', '24GB GDDR6X', 4200.00, 5, 4, 7, 'RTX4090'),
(50, 'AMD Radeon RX 7900 XTX', '24GB GDDR6', 4100.00, 6, 4, 5, 'RX7900XTX'),
/*gabinetes*/
(51, 'NZXT H510', 'ATX Mid Tower, vidrio templado', 350.00, 14, 7, 18, 'H510-BK'),
(52, 'Corsair 4000D Airflow', 'ATX Mid Tower, flujo optimizado', 370.00, 16, 7, 10, 'CC-9011200-WW'),
(53, 'Cooler Master Q300L', 'Micro ATX, frontal ventilado', 290.00, 18, 7, 11, 'MCB-Q300L-KANN-S00'),
(54, 'Phanteks Eclipse P400A', 'ATX, malla frontal, RGB', 360.00, 12, 7, 9, 'PH-EC400ATG'),
(55, 'Lian Li Lancool II Mesh', 'ATX Mid Tower, panel removible', 380.00, 10, 7, 9, 'LANCOOL2MESH'),
(56, 'Thermaltake V200', 'Vidrio templado, RGB incluido', 330.00, 13, 7, 20, 'CA-1K8-00M1WN-01'),
(57, 'Fractal Design Meshify C', 'ATX, diseño de malla agresiva', 400.00, 11, 7, 9, 'FD-CA-MESH-C-BKO'),
(58, 'DeepCool Matrexx 55', 'ATX, iluminación LED frontal', 310.00, 15, 7, 9, 'DP-ATX-MATREXX55'),
(59, 'MSI MAG Forge 100R', 'Vidrio templado, RGB doble fan', 345.00, 9, 7, 10, '306-7G10R11-W57'),
(60, 'Aerocool Cylon', 'ATX, franja RGB lateral', 270.00, 17, 7, 9, 'AC-CY-ATX'),
/*fuentepoder*/
(61, 'Corsair CV550', '550W 80 Plus Bronze, no modular', 240.00, 20, 8, 10, 'CP-9020210-NA'),
(62, 'EVGA 600 BR', '600W 80 Plus Bronze, no modular', 260.00, 18, 8, 17, '100-BR-0600-K1'),
(63, 'Cooler Master MWE 650 White', '650W 80 Plus White', 250.00, 16, 8, 11, 'MPE-6501-ACABW'),
(64, 'Thermaltake Smart 500W', '500W 80 Plus White', 230.00, 22, 8, 20, 'PS-SPD-0500NPCWUS-W'),
(65, 'Seasonic S12III 550', '550W 80 Plus Bronze', 270.00, 15, 8, 9, 'SSR-550GB3'),
(66, 'Corsair RM750x', '750W 80 Plus Gold, full modular', 420.00, 12, 8, 10, 'CP-9020179-NA'),
(67, 'Be Quiet! System Power 9 600W', '80 Plus Bronze', 280.00, 14, 8, 25, 'BN246'),
(68, 'EVGA SuperNOVA 850 G5', '850W 80 Plus Gold, modular', 480.00, 10, 8, 17, '220-G5-0850-X1'),
(69, 'Thermaltake Toughpower GX1 600W', '80 Plus Gold', 350.00, 13, 8, 20, 'PS-TPD-0600NNFAGU-1'),
(70, 'Cooler Master V850 SFX', '850W 80 Plus Gold, compacta', 520.00, 9, 8, 11, 'MPY-8501-SFHAGV'),
/*ventilador*/
(71, 'Cooler Master SickleFlow 120 V2', 'Fan 120mm RGB, 3 pines', 65.00, 30, 9, 11, 'R4-120R-20PC-R1'),
(72, 'Noctua NF-P12 Redux-1700 PWM', 'Fan 120mm, silencioso', 85.00, 25, 9, 25, 'NF-P12-REDUX'),
(73, 'Corsair AF120 Elite', '120mm, alto flujo de aire', 90.00, 22, 9, 10, 'CO-9050140-WW'),
(74, 'ARCTIC F12 PWM', 'Fan económico, 120mm', 55.00, 35, 9, 9, 'ACFAN00119A'),
(75, 'Thermaltake Pure 12 ARGB', 'Fan 120mm RGB, controlado', 95.00, 20, 9, 20, 'CL-F064-PL12SW-A'),
(76, 'Be Quiet! Pure Wings 2', '120mm, silencioso', 88.00, 18, 9, 25, 'BL046'),
(77, 'Cooler Master MasterFan MF120 Halo', 'Fan RGB doble anillo', 110.00, 15, 9, 11, 'MF120-HALO'),
(78, 'Lian Li UNI FAN SL120', 'Fan modular RGB', 120.00, 10, 9, 9, 'UF-SL120-1B'),
(79, 'NZXT AER RGB 2 120mm', 'Fan con iluminación integrada', 115.00, 12, 9, 18, 'HF-28120-B1'),
(80, 'Fractal Design Aspect 12 RGB', 'Ventilador silencioso y estético', 105.00, 14, 9, 9, 'FD-F-AS1-1208'),
/*refrigeracioncpu*/
(81, 'Cooler Master Hyper 212 Black Edition', 'Aire, 120mm, 4 heatpipes', 160.00, 14, 10, 11, 'RR-212S-20PK-R1'),
(82, 'Noctua NH-D15', 'Doble torre, alto rendimiento', 420.00, 10, 10, 25, 'NH-D15'),
(83, 'be quiet! Dark Rock Pro 4', 'Enfriamiento silencioso premium', 390.00, 8, 10, 25, 'BK022'),
(84, 'Corsair H100i Elite Capellix', 'Líquida 240mm RGB', 520.00, 11, 10, 10, 'CW-9060046-WW'),
(85, 'NZXT Kraken X63', 'Líquida 280mm RGB', 550.00, 9, 10, 18, 'RL-KRX63-01'),
(86, 'Thermaltake TH240 ARGB', 'Líquida 240mm RGB', 480.00, 12, 10, 20, 'CL-W286-PL12SW-A'),
(87, 'DeepCool GAMMAXX 400 V2', 'Aire, 120mm, económico', 170.00, 15, 10, 9, 'DP-MCH4-GMX400V2'),
(88, 'ARCTIC Freezer 34 eSports DUO', 'Aire, doble ventilador', 210.00, 13, 10, 9, 'ACFRE00061A'),
(89, 'Cooler Master MasterLiquid ML240L V2', 'Líquida 240mm RGB', 495.00, 10, 10, 11, 'MLW-D24M-A18PC-R2'),
(90, 'ID-COOLING SE-224-XT', 'Aire, compacto y eficaz', 140.00, 17, 10, 9, 'SE-224-XT-BLACK'),
/*pastatermica*/
(91, 'Arctic MX-4', 'Compuesto térmico de alto rendimiento, 4g', 35.00, 25, 11, 9, 'MX-4'),
(92, 'Noctua NT-H1', 'Pasta térmica premium, 3.5g', 40.00, 20, 11, 25, 'NT-H1'),
(93, 'Thermal Grizzly Kryonaut', 'Conductividad térmica extrema, 1g', 55.00, 15, 11, 9, 'TG-K-001-RS'),
(94, 'Cooler Master MasterGel Pro V2', 'Conductividad 9W/mK, 1.5ml', 42.00, 18, 11, 11, 'MGZ-NDSG-N15M-R2'),
(95, 'Corsair TM30', 'Pasta térmica con baja resistencia térmica', 39.00, 17, 11, 10, 'CT-9010001-WW'),
(96, 'DeepCool Z9', 'Conductividad térmica 4W/mK', 28.00, 22, 11, 9, 'Z9'),
(97, 'Thermaltake TG-7', 'Alta conductividad térmica, 4g', 33.00, 20, 11, 20, 'CL-O0028-A'),
(98, 'ARCTIC Silver 5', 'Compuesto térmico con plata, 3.5g', 47.00, 16, 11, 9, 'AS5-3.5G'),
(99, 'Noctua NT-H2', 'Nueva fórmula térmica avanzada', 52.00, 12, 11, 25, 'NT-H2'),
(100, 'ID-COOLING TP-7', 'Compuesto eficiente y económico', 26.00, 30, 11, 9, 'TP-7'),
/*sistemaoperador*/
(101, 'Windows 10 Home OEM', 'Licencia digital para 1 PC', 420.00, 20, 12, 16, 'KW9-00139'),
(102, 'Windows 10 Pro OEM', 'Versión profesional, 1 licencia', 480.00, 18, 12, 16, 'FQC-09131'),
(103, 'Windows 11 Home', 'Licencia digital oficial', 440.00, 22, 12, 16, 'KW9-00632'),
(104, 'Windows 11 Pro', 'Sistema operativo avanzado', 520.00, 15, 12, 16, 'FQC-10528'),
(105, 'Ubuntu 22.04 LTS USB', 'Sistema operativo libre, USB booteable', 30.00, 25, 12, 9, 'UBU-2204-USB'),
(106, 'Linux Mint Cinnamon USB', 'Sistema operativo preinstalado en USB', 28.00, 28, 12, 9, 'LMINT-CIN-21'),
(107, 'Zorin OS 16 Pro', 'Alternativa a Windows, moderna', 60.00, 14, 12, 9, 'ZOS-16PRO'),
(108, 'Windows Server 2022 Standard', 'Sistema para servidores', 1450.00, 10, 12, 16, 'P73-08328'),
(109, 'Windows 10 Pro Education', 'Versión educativa Pro', 470.00, 12, 12, 16, 'FQC-09525'),
(110, 'Elementary OS 7 Hera', 'Sistema operativo visualmente limpio', 35.00, 20, 12, 9, 'EOS-7'),
/*antivirus*/
(111, 'Kaspersky Internet Security 1 Año', 'Protección para 1 dispositivo', 120.00, 20, 13, 9, 'KIS-1A-PC'),
(112, 'Norton 360 Deluxe', 'Protección para hasta 5 dispositivos', 160.00, 18, 13, 9, 'N360-DELUXE'),
(113, 'ESET NOD32 Antivirus 1 Año', 'Antivirus ligero y confiable', 110.00, 22, 13, 9, 'EAV-1Y'),
(114, 'Bitdefender Total Security', 'Protección completa, multiplataforma', 170.00, 16, 13, 9, 'BTS-2024'),
(115, 'McAfee Total Protection', 'Seguridad en línea integral', 150.00, 21, 13, 9, 'MTP-1D'),
(116, 'Avast Premium Security', 'Protección avanzada contra malware', 130.00, 19, 13, 9, 'APS-2024'),
(117, 'AVG Internet Security', 'Antivirus con escudo web y email', 115.00, 17, 13, 9, 'AVG-IS'),
(118, 'Panda Dome Advanced', 'Incluye control parental y VPN', 125.00, 14, 13, 9, 'PDA-2024'),
(119, 'Kaspersky Total Security 3 PCs', 'Protección familiar, múltiples dispositivos', 180.00, 12, 13, 9, 'KTS-3PC'),
(120, 'Trend Micro Maximum Security', 'Detección avanzada de amenazas', 145.00, 15, 13, 9, 'TMMS-2024'),
/*monitor*/
(121, 'LG UltraGear 24GN600-B', '24", Full HD, 144Hz, 1ms', 850.00, 12, 14, 6, '24GN600-B'),
(122, 'ASUS TUF Gaming VG249Q1R', '23.8", Full HD, 165Hz, IPS', 890.00, 14, 14, 1, 'VG249Q1R'),
(123, 'Samsung Odyssey G3 24"', 'Full HD, 144Hz, FreeSync', 870.00, 10, 14, 16, 'LF24G35TFWLXPE'),
(124, 'AOC 24G2', '24", IPS, 144Hz, Full HD', 840.00, 13, 14, 9, '24G2'),
(125, 'ViewSonic XG2431', '24", Full HD, 240Hz, IPS', 950.00, 9, 14, 9, 'XG2431'),
(126, 'MSI Optix G241', '23.8", Full HD, 144Hz, IPS', 860.00, 11, 14, 10, 'G241'),
(127, 'Gigabyte G24F 2', '23.8", 165Hz, 1ms MPRT', 875.00, 10, 14, 8, 'G24F 2'),
(128, 'BenQ MOBIUZ EX2510S', '24.5", 165Hz, HDRi, IPS', 930.00, 8, 14, 9, 'EX2510S'),
(129, 'HP X24ih', '23.8", Full HD, 144Hz', 845.00, 13, 14, 2, 'X24ih'),
(130, 'Dell S2522HG', '24.5", 240Hz, IPS, FreeSync', 990.00, 7, 14, 3, 'S2522HG'),
/*mouse*/
(131, 'Logitech G502 HERO', 'Sensor HERO 25K, 11 botones programables', 220.00, 20, 15, 4, 'G502-HERO'),
(132, 'Razer DeathAdder V2', 'Sensor óptico 20K DPI, RGB', 230.00, 18, 15, 12, 'RZ01-03210100-R3U1'),
(133, 'SteelSeries Rival 3', 'Sensor óptico TrueMove Core, RGB', 180.00, 22, 15, 9, '62513'),
(134, 'Corsair Harpoon RGB Wireless', 'Mouse inalámbrico, 10,000 DPI', 210.00, 15, 15, 10, 'CH-9311011-NA'),
(135, 'Redragon M711 Cobra', 'RGB, 10,000 DPI, 7 botones', 150.00, 30, 15, 9, 'M711'),
(136, 'HyperX Pulsefire FPS Pro', 'Sensor Pixart 3389, RGB', 200.00, 17, 15, 19, 'HX-MC003B'),
(137, 'Cooler Master MM711', 'Ultraligero, RGB, 16K DPI', 240.00, 14, 15, 11, 'MM-711-KKOL1'),
(138, 'Glorious Model O', 'Honeycomb, ultra liviano, RGB', 250.00, 10, 15, 9, 'GO-BLACK'),
(139, 'Logitech G203 Lightsync', 'RGB, 8000 DPI', 160.00, 25, 15, 4, 'G203-LS'),
(140, 'Razer Basilisk V3', 'Ergonómico, 26K DPI, RGB', 270.00, 13, 15, 12, 'RZ01-04000100-R3U1'),
/*teclado*/
(141, 'Logitech G213 Prodigy', 'Teclado gaming RGB, membrana', 230.00, 20, 16, 4, 'G213'),
(142, 'Redragon Kumara K552', 'Mecánico, switches rojos, RGB', 190.00, 25, 16, 9, 'K552-RGB'),
(143, 'Razer Cynosa V2', 'Membrana, retroiluminado RGB', 210.00, 18, 16, 12, 'RZ03-03400100-R3U1'),
(144, 'Corsair K55 RGB Pro', 'Teclado gaming con macros', 240.00, 15, 16, 10, 'CH-9226765-NA'),
(145, 'HyperX Alloy Core RGB', 'Membrana silenciosa, RGB', 200.00, 22, 16, 19, 'HX-KB5ME2-US'),
(146, 'SteelSeries Apex 3', 'Teclado silencioso, RGB', 220.00, 16, 16, 9, '64807'),
(147, 'Cooler Master CK552', 'Mecánico, switches rojos, RGB', 260.00, 14, 16, 11, 'CK-552-GKMR1-US'),
(148, 'Logitech G915 TKL', 'Mecánico inalámbrico, RGB', 560.00, 10, 16, 4, 'G915-TKL'),
(149, 'Razer BlackWidow V3', 'Mecánico, switches verdes, RGB', 340.00, 12, 16, 12, 'RZ03-03540100-R3U1'),
(150, 'EVGA Z12', 'Teclado gaming RGB, resistente salpicaduras', 180.00, 20, 16, 17, 'Z12-RGB'),
/*audifonos*/
(151, 'Logitech G733 Lightspeed', 'Inalámbrico, RGB, micrófono removible', 420.00, 12, 17, 4, 'G733'),
(152, 'HyperX Cloud II', 'Sonido envolvente 7.1, con micrófono', 390.00, 15, 17, 19, 'HX-HSCL-II'),
(153, 'Razer BlackShark V2 X', 'Ligero, sonido envolvente, mic.', 360.00, 18, 17, 12, 'RZ04-03240100-R3U1'),
(154, 'Corsair HS60 PRO Surround', 'Conector USB, sonido 7.1', 370.00, 13, 17, 10, 'CA-9011213-NA'),
(155, 'SteelSeries Arctis 3', 'Diseño cómodo, compatible multiplataforma', 350.00, 20, 17, 9, '61505'),
(156, 'Redragon Zeus 2 H510', 'Sonido 7.1, diseño robusto', 290.00, 22, 17, 9, 'H510-ZEUS2'),
(157, 'Logitech G435 Lightspeed', 'Bluetooth + inalámbrico, livianos', 310.00, 17, 17, 4, 'G435'),
(158, 'ASUS TUF Gaming H3', 'Sonido envolvente, con micrófono', 330.00, 14, 17, 1, 'TUF-GAMING-H3'),
(159, 'Razer Kraken X', 'Ligero, sonido 7.1, micrófono ajustable', 320.00, 16, 17, 12, 'RZ04-02890100-R3U1'),
(160, 'Cooler Master MH630', 'Jack 3.5mm, diseño clásico', 300.00, 19, 17, 11, 'MH-630'),
/*silla*/
(161, 'Cougar Armor One', 'Silla gamer con soporte lumbar y cuello', 750.00, 10, 18, 9, 'Armor-One'),
(162, 'DXRacer Formula Series', 'Diseño ergonómico, respaldo ajustable', 980.00, 8, 18, 9, 'F-Series'),
(163, 'Corsair T3 Rush', 'Espuma de alta densidad, respaldo 180°', 940.00, 9, 18, 10, 'CF-9010031-WW'),
(164, 'Noblechairs Hero', 'Diseño premium, soporte lumbar ajustable', 1200.00, 6, 18, 9, 'HERO-BLACK'),
(165, 'Secretlab TITAN Evo 2022', 'Espuma patentada, soporte lumbar L-ADAPT™', 1350.00, 5, 18, 9, 'TITAN-EVO-22'),
(166, 'Razer Iskur', 'Apoyo lumbar ergonómico, espuma moldeada', 1100.00, 7, 18, 12, 'RZ38-02770200-R3U1'),
(167, 'Thermaltake X Comfort', 'Reposabrazos 4D, cuero sintético', 990.00, 8, 18, 20, 'GC-XCO-BBLFDL-01'),
(168, 'Vertagear SL4000', 'Estructura de acero, cojines incluidos', 950.00, 9, 18, 9, 'SL4000'),
(169, 'Cooler Master Caliber R2', 'Espuma moldeada, diseño ergonómico', 930.00, 10, 18, 11, 'CMI-GCR2-2019'),
(170, 'Anda Seat Jungle Series', 'Soporte lumbar y cervical, base de metal', 890.00, 11, 18, 9, 'AD12XL-BLACK'),
/*escritorio*/
(171, 'Arozzi Arena Gaming Desk', 'Escritorio curvo, alfombrilla completa', 1250.00, 7, 19, 9, 'Arena-Black'),
(172, 'Secretlab MAGNUS Metal Desk', 'Diseño metálico, gestión de cables', 1450.00, 5, 19, 9, 'MAGNUS-STD'),
(173, 'Eureka Ergonomic Z1-S', 'Escritorio gamer con luces LED', 1100.00, 9, 19, 9, 'ERK-Z1S-BLACK'),
(174, 'Flexispot E5 Standing Desk', 'Altura ajustable, estructura robusta', 1350.00, 6, 19, 9, 'E5-BK-140'),
(175, 'Trust GXT 711 Dominus', 'Diseño gamer, superficie resistente', 950.00, 10, 19, 9, 'GXT711'),
(176, 'DXRacer GD/1000/N', 'Escritorio con bandeja de cables', 1200.00, 7, 19, 9, 'GD1000N'),
(177, 'Thermaltake ToughDesk 500L RGB', 'Escritorio en L con RGB sincronizado', 2100.00, 3, 19, 20, 'TD500L-RGB'),
(178, 'Cougar Mars Gaming Desk', 'Estructura metálica, luces RGB', 1300.00, 6, 19, 9, 'Mars-Desk'),
(179, 'Cooler Master GD160 ARGB', 'Escritorio RGB, superficie amplia', 1400.00, 4, 19, 11, 'GD160-ARGB'),
(180, 'Vitesse Gaming Desk 55"', 'Económico, portavaso y ganchos incluidos', 890.00, 11, 19, 9, 'VT-GD55'),
/*volantes*/
(181, 'Logitech G29 Driving Force', 'Volante con pedales, compatible con PC/PS', 1550.00, 8, 20, 4, 'G29-DF'),
(182, 'Thrustmaster T300 RS GT', 'Volante con base Force Feedback, pedales GT', 1850.00, 6, 20, 9, 'T300RS-GT'),
(183, 'Hori Racing Wheel Apex', 'Volante económico, sin FFB, compatible con PS4/PC', 650.00, 12, 20, 9, 'RWA-APEX'),
(184, 'Fanatec CSL Elite', 'Volante premium con FFB, pedales ajustables', 2200.00, 4, 20, 9, 'CSL-ELITE-BASE'),
(185, 'Thrustmaster T150 Pro', 'Force Feedback, 3 pedales incluidos', 1250.00, 7, 20, 9, 'T150-PRO'),
(186, 'PXN V9', 'Volante de 900°, con palanca de cambios', 890.00, 9, 20, 9, 'PXN-V9'),
(187, 'Logitech G923 TrueForce', 'Volante avanzado con tecnología TrueForce', 1650.00, 6, 20, 4, 'G923-RACE'),
(188, 'Thrustmaster TMX PRO', 'Versión para Xbox con pedales T3PA', 1390.00, 5, 20, 9, 'TMX-PRO'),
(189, 'Fanatec GT DD Pro', 'Direct Drive, alto rendimiento, oficial Gran Turismo', 3500.00, 3, 20, 9, 'GT-DDPRO'),
(190, 'Logitech Driving Force Shifter', 'Palanca de cambios compatible G29/G923', 450.00, 10, 20, 4, 'DF-SHIFTER'),
/*ssd*/
(191, 'Samsung 980 PRO 1TB', 'NVMe PCIe 4.0, lectura 7000MB/s', 620.00, 14, 5, 16, 'MZ-V8P1T0BW'),
(192, 'WD Black SN850X 1TB', 'PCIe Gen4, hasta 7300MB/s', 610.00, 12, 5, 9, 'WDS100T2X0E'),
(193, 'Crucial P5 Plus 1TB', 'NVMe PCIe 4.0, lectura 6600MB/s', 550.00, 18, 5, 9, 'CT1000P5PSSD8'),
(194, 'Kingston KC3000 1TB', 'Alto rendimiento, PCIe 4.0', 565.00, 15, 5, 9, 'SKC3000S/1024G'),
(195, 'ADATA XPG GAMMIX S70 Blade 1TB', 'PCIe Gen4, hasta 7400MB/s', 575.00, 16, 5, 9, 'AGAMMIXS70B-1T-C'),
(196, 'Sabrent Rocket 4 Plus 1TB', 'SSD M.2 Gen4, lectura 7000MB/s', 580.00, 11, 5, 9, 'SB-RKT4P-1TB'),
(197, 'PNY XLR8 CS3140 1TB', 'SSD M.2 NVMe Gen4', 530.00, 13, 5, 9, 'M280CS3140-1TB-RB'),
(198, 'TeamGroup T-Force Cardea Z440 1TB', 'PCIe Gen4, disipador térmico incluido', 545.00, 14, 5, 9, 'TM8FP7001T0C101'),
(199, 'Gigabyte AORUS Gen4 1TB', 'SSD M.2 con cobre térmico', 595.00, 10, 5, 8, 'GP-AG40TB'),
(200, 'Patriot Viper VP4300 1TB', 'M.2 PCIe Gen4, alto rendimiento', 560.00, 12, 5, 9, 'VP4300-1TBM28H');


-- Insertar Órdenes de Pedido de Ejemplo
INSERT INTO orden_pedido (cliente_dni, vendedor_asignado_id, tecnico_asignado_id, total, tipo_pedido, observaciones, detalles_componentes, id_estado) VALUES
('20456789', '87654321', '44332211', 2547.00, 'ARMAR_PC', 'PC Gaming básico', 'CONFIGURACIÓN PC PERSONALIZADA:\n\nProcesador:\n- AMD Ryzen 5 5600X (Cant: 1, Marca: AMD)\n\nTarjeta Madre:\n- ASUS B450M-A PRO MAX (Cant: 1, Marca: ASUS)\n\nMemoria RAM:\n- Corsair Vengeance LPX 16GB (Cant: 1, Marca: Corsair)', 2),
('30567890', '87654321', NULL, 449.00, 'PRODUCTO_COMPLETO', 'Monitor para oficina', 'PRODUCTOS INDIVIDUALES:\n\n- ASUS VA24EHE 24" (Cant: 1, Precio: S/ 449.00)', 1),
('40678901', '11223344', '55667788', 1848.00, 'ARMAR_PC', 'PC para diseño gráfico', 'CONFIGURACIÓN PC PERSONALIZADA:\n\nProcesador:\n- Intel Core i7-12700K (Cant: 1, Marca: Intel)\n\nTarjeta de Video:\n- AMD RX 6600 XT (Cant: 1, Marca: AMD)', 3);

-- Insertar Detalles de Pedido EXACTOS (sin precio_unitario ni subtotal)
INSERT INTO detalle_pedido (id_orden, id_producto, cantidad) VALUES
-- Detalles para orden 1 (PC Gaming básico)
(1, 1, 1), -- AMD Ryzen 5 5600X
(1, 5, 1), -- ASUS B450M-A PRO MAX  
(1, 8, 1), -- Corsair Vengeance LPX 16GB
(1, 13, 1), -- Samsung 980 SSD 1TB
(1, 16, 1), -- Corsair CV550 550W
(1, 19, 1), -- Cooler Master MasterBox Q300L

-- Detalles para orden 2 (Monitor)
(2, 22, 1), -- ASUS VA24EHE 24"

-- Detalles para orden 3 (PC diseño gráfico)
(3, 4, 1), -- Intel Core i7-12700K
(3, 12, 1); -- AMD RX 6600 XT

-- =========================
-- VISTAS ÚTILES
-- =========================


-- Verificar que los roles están correctos
SELECT * FROM roles ORDER BY id;


-- Vista productos completos
CREATE VIEW vista_productos_completa AS
SELECT 
    p.id_producto,
    p.nombre,
    p.descripcion,
    p.precio,
    p.cantidad_stock,
    c.nombre AS categoria,
    m.nombre AS marca,
    p.modelo
FROM producto p
JOIN categoria_producto c ON p.id_categoria = c.id_categoria
JOIN marca m ON p.id_marca = m.id_marca;

-- Vista órdenes completas
CREATE VIEW vista_ordenes_completa AS
SELECT 
    o.id_orden,
    o.fecha_orden,
    CONCAT(c.nombre, ' ', c.apellido) AS cliente,
    c.dni AS dni_cliente,
    CONCAT(v.nombre, ' ', v.apellido) AS vendedor,
    CONCAT(t.nombre, ' ', t.apellido) AS tecnico,
    o.total,
    o.tipo_pedido,
    e.descripcion AS estado
FROM orden_pedido o
JOIN cliente c ON o.cliente_dni = c.dni
LEFT JOIN usuarios v ON o.vendedor_asignado_id = v.id
LEFT JOIN usuarios t ON o.tecnico_asignado_id = t.id
JOIN estado e ON o.id_estado = e.id_estado;

-- Vista detalle de pedidos EXACTA (sin precio_unitario ni subtotal calculados dinámicamente)
CREATE VIEW vista_detalle_pedidos AS
SELECT 
    dp.id_detalle,
    dp.id_orden,
    p.nombre AS producto,
    dp.cantidad,
    p.precio AS precio_unitario,
    (dp.cantidad * p.precio) AS subtotal,
    m.nombre AS marca,
    c.nombre AS categoria
FROM detalle_pedido dp
JOIN producto p ON dp.id_producto = p.id_producto
JOIN marca m ON p.id_marca = m.id_marca
JOIN categoria_producto c ON p.id_categoria = c.id_categoria;

-- =========================
-- ÍNDICES PARA RENDIMIENTO
-- =========================
CREATE INDEX idx_producto_categoria ON producto(id_categoria);
CREATE INDEX idx_producto_marca ON producto(id_marca);
CREATE INDEX idx_orden_cliente ON orden_pedido(cliente_dni);
CREATE INDEX idx_orden_fecha ON orden_pedido(fecha_orden);
CREATE INDEX idx_orden_estado ON orden_pedido(id_estado);
CREATE INDEX idx_detalle_orden ON detalle_pedido(id_orden);
CREATE INDEX idx_cliente_activo ON cliente(activo);

-- =========================
-- VERIFICACIÓN FINAL
-- =========================
SELECT 'Base de datos Akira creada exitosamente - 100% compatible con el proyecto Java' AS resultado;
SELECT COUNT(*) AS total_productos FROM producto;
SELECT COUNT(*) AS total_clientes FROM cliente;
SELECT COUNT(*) AS total_usuarios FROM usuarios;
SELECT COUNT(*) AS total_ordenes FROM orden_pedido;
SELECT COUNT(*) AS total_roles FROM roles;
SELECT COUNT(*) AS total_estados FROM estado;