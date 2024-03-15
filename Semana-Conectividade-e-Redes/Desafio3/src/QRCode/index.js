const express = require('express');
const qr = require('qrcode');
const app = express();

const PORT = process.env.PORT || 3000;
const URL = process.env.URL || 'http://play.brunofreitas.tec.br';

app.get('/', (req, res) => {
  // Gere o QR code para a URL especificada
  qr.toDataURL(URL, (err, url) => {
    if (err) return res.send('Erro ao gerar QR code');
    res.send(`<img src="${url}" alt="QR Code">`);
  });
});

// Inicie o servidor
app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});
