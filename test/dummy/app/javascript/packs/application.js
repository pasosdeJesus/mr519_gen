/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

console.log('Hola mundo desde Webpacker')

require("@rails/ujs").start()
require("turbolinks").start()

import {$, jQuery} from "jquery";

import "popper.js"
import "bootstrap"
import "chosen-js/chosen.jquery"
import 'bootstrap-datepicker'
import 'bootstrap-datepicker/dist/locales/bootstrap-datepicker.es.min.js'
import 'knockout'
import 'jquery-ui'
import 'pick-a-color'
import tinycolor from 'tinycolor2'
import 'jquery-ui/ui/widgets/autocomplete'
import 'gridstack/dist/gridstack'
import 'gridstack/dist/gridstack.all'
