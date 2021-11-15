module.exports = [
  {
    type: "input",
    name: "root_path",
    message: "Ruta donde se va a crear el job script",
  },
  {
    type: "input",
    name: "variable_name",
    message: "nombre de la variable",
  },
  {
    type: "input",
    name: "rd_secret_name",
    message: "nombre del secreto en rundeck",
  },
];
