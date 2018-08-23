/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
function sleep_s(secs) {
  secs = (+new Date) + secs * 1000;
  while ((+new Date) < secs);
}

const button = document.getElementById('gerar');
const refresh = document.getElementById('my-btn');

const placares = document.querySelectorAll('.hidden');

button.addEventListener('click', (event) => {
  refresh.classList.add('fa-spin');
  placares.forEach((placar) => {
  placar.classList.toggle('hidden');
  });
});



