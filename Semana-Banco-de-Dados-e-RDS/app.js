const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const port = 3000;

// Configuração do banco de dados PostgreSQL
const pool = new Pool({
  user: 'seu_usuario',
  host: 'seu_host',
  database: 'seu_banco_de_dados',
  password: 'sua_senha',
  port: 5432, // Porta padrão do PostgreSQL
});

// Rota para lidar com a solicitação de dados do PostgreSQL
app.get('/dados', async (req, res) => {
  try {
    // Conectar ao banco de dados
    const client = await pool.connect();
    
    // Executar consulta SQL para obter dados
    const result = await client.query('SELECT * FROM sua_tabela');
    const data = result.rows;

    // Renderizar a página HTML com os dados obtidos
    res.sendFile(path.join(__dirname, 'index.html'));

    // Liberar o cliente da conexão com o banco de dados
    client.release();
  } catch (error) {
    console.error('Erro ao buscar dados do banco:', error);
    res.status(500).send('Erro ao buscar dados do banco');
  }
});

// Configurar o servidor para ouvir na porta especificada
app.listen(port, () => {
  console.log(`Servidor iniciado em http://localhost:${port}`);
});
