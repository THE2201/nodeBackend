const express = require('express');
const mongoose = require('mongoose');
const Product = require('./models/product.model.js');
const app = express();
const productRoute = require('./routes/product.route.js');

//Middlewares
app.use(express.json());
//to add form url encoded
app.use(express.urlencoded({ extended: false }));
//end middlewares


mongoose.connect('mongodb://127.0.0.1:27017/backendDB')
    .then(() => {
        console.log('Conectado a MongoDB');
    })
    .catch((err) => {
        console.log('No conecto a DB: ', err);
    })

app.listen(3000, () => {
    console.log('Server is running opn port 3000');
});

//routes
app.use("/api/products", productRoute);




app.post('/api/products', (req, res) => {
    console.log(req.body);
    res.send(req.body);

});


