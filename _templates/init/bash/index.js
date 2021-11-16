// init/with-prompt/index.js
module.exports = {
  prompt: ({ prompter }) => {
    return prompter
      .prompt({
        type: "input",
        name: "qty_variables",
        message: "Cantidad de variables",
      })
      .then(({ qty_variables }) => {
        var variableNameQuestions = [
          {
            name: "qty_variables",
            type: "input",
            value: qty_variables,
            skip: true,
          },
          {
            type: "input",
            name: "root_path",
            message: "Ruta del job",
          },
        ];
        for (var i = 1; i <= qty_variables; i++) {
          variableNameQuestions.push({
            type: "input",
            name: `variable_name_${i}`,
            message: `Nombre de la variable ${i}`,
          });
        }
        return prompter.prompt(variableNameQuestions);
      });
  },
};
