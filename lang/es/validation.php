<?php

return [
    'required' => 'El campo :attribute es obligatorio.',
    'required_if' => 'El campo :attribute es obligatorio para esta opción.',
    'string' => 'El campo :attribute debe ser texto.', 'integer' => 'El campo :attribute debe ser un número entero.',
    'boolean' => 'La opción :attribute no es válida.', 'array' => 'El campo :attribute debe contener una lista.',
    'min' => ['string' => ':attribute debe tener al menos :min caracteres.', 'numeric' => ':attribute debe ser como mínimo :min.', 'array' => 'Seleccione al menos :min opción.'],
    'max' => ['string' => ':attribute no debe superar :max caracteres.', 'numeric' => ':attribute no debe superar :max.', 'file' => 'El archivo no debe superar :max KB.'],
    'date' => 'Ingrese una fecha válida en :attribute.', 'date_format' => 'El campo :attribute debe tener el formato :format.',
    'after' => ':attribute debe ser posterior a :date.', 'after_or_equal' => ':attribute debe ser igual o posterior a :date.',
    'before_or_equal' => ':attribute debe ser igual o anterior a :date.',
    'email' => 'Ingrese un correo válido.', 'unique' => 'El valor de :attribute ya está registrado.',
    'exists' => 'El registro seleccionado no existe.', 'in' => 'La opción seleccionada no es válida.',
    'regex' => 'El formato de :attribute no es válido.', 'digits' => ':attribute debe tener :digits dígitos.',
    'confirmed' => 'La confirmación de la contraseña no coincide.', 'current_password' => 'La contraseña actual es incorrecta.',
    'different' => 'La nueva contraseña debe ser distinta a la actual.', 'file' => 'Seleccione un archivo válido.',
    'mimes' => 'El archivo debe ser de tipo :values.', 'uploaded' => 'No se pudo cargar el archivo; revise su tamaño.',
    'distinct' => 'No repita opciones.', 'between' => ['numeric' => ':attribute debe estar entre :min y :max.'],
    'lte' => ['numeric' => ':attribute no puede ser mayor que :value.'],
    'attributes' => ['username' => 'usuario', 'password' => 'contraseña', 'actual' => 'contraseña actual', 'nombres' => 'nombre completo', 'dni' => 'DNI', 'fecha_inicio' => 'fecha de inicio', 'fecha_fin' => 'fecha final', 'hora_entrada' => 'hora de entrada', 'hora_salida' => 'hora de salida', 'inicio_refrigerio' => 'salida a refrigerio', 'fin_refrigerio' => 'retorno del refrigerio', 'periodo_id' => 'periodo', 'asistencia_id' => 'jornada', 'motivo' => 'motivo', 'nota' => 'sustento', 'dias' => 'días de trabajo', 'usados_iniciales' => 'días usados inicialmente', 'dias_devengados' => 'días reconocidos'],
];
