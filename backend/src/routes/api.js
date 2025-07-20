const express = require('express');
   const router = express.Router();
   const pool = require('../config/db');
   const jwt = require('jsonwebtoken');

   // Middleware para autenticación
   const authenticateToken = (req, res, next) => {
     const token = req.headers['authorization']?.split(' ')[1];
     if (!token) return res.status(401).json({ error: 'Token requerido' });

     jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
       if (err) return res.status(403).json({ error: 'Token inválido' });
       req.user = user;
       next();
     });
   };

   // Login
   router.post('/login', async (req, res) => {
     const { correo, contraseña } = req.body;
     try {
       const [rows] = await pool.query('SELECT * FROM usuarios WHERE correo = ?', [correo]);
       const user = rows[0];
       if (!user || user.contraseña_hash !== contraseña) { // En producción, usar bcrypt
         return res.status(401).json({ error: 'Credenciales inválidas' });
       }
       const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
       res.json({ token, user: { id: user.id, nombre: user.nombre, correo: user.correo } });
     } catch (error) {
       res.status(500).json({ error: 'Error en el servidor' });
     }
   });

   // Obtener transacciones
   router.get('/transacciones', authenticateToken, async (req, res) => {
     try {
       const [rows] = await pool.query(
         'SELECT t.*, c.nombre as categoria, cu.nombre as cuenta ' +
         'FROM transacciones t ' +
         'LEFT JOIN categorias c ON t.categoria_id = c.id ' +
         'LEFT JOIN cuentas cu ON t.cuenta_id = cu.id ' +
         'WHERE t.usuario_id = ?',
         [req.user.id]
       );
       res.json(rows);
     } catch (error) {
       console.log(error); // Agrega esto para depuración
        res.status(500).json({ error: 'Error en el servidor' });
     }
   });

   // Crear transacción
   router.post('/transacciones', authenticateToken, async (req, res) => {
     const { tipo, importe, fecha, categoria_id, cuenta_id, nota, descripcion } = req.body;
     try {
       const [result] = await pool.query(
         'INSERT INTO transacciones (usuario_id, tipo, importe, fecha, categoria_id, cuenta_id, nota, descripcion) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
         [req.user.id, tipo, importe, fecha, categoria_id, cuenta_id, nota, descripcion]
       );
       res.json({ id: result.insertId, message: 'Transacción creada' });
     } catch (error) {
       res.status(500).json({ error: 'Error al crear transacción' });
     }
   });

   module.exports = router;