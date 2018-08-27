/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// function sleep_s(secs) {
//   secs = (+new Date) + secs * 1000;
//   while ((+new Date) < secs);
// }

const button = document.getElementById('gerar');
const refresh = document.getElementById('my-btn');
const teams = document.querySelectorAll('.team');

const placares = document.querySelectorAll('.hidden');

button.addEventListener('click', (event) => {
  let i = 0;
  let j = 1;
  refresh.classList.add('fa-spin');
  placares.forEach((placar) => {
  placar.classList.toggle('hidden');

    if (placar.text === "1 x 0" || placar.text === "2 x 0") {
      teams[i].classList.add('winner-score');
      teams[j].classList.add('loser-score');
    } else if (placar.text === "0 x 1" || placar.text === "0 x 2") {
      teams[i].classList.add('loser-score');
      teams[j].classList.add('winner-score');
    } else if (placar.text === "- x -") {
      teams[i].classList.add('draw-score');
      teams[j].classList.add('draw-score');
    } else {
      teams[i].classList.add('draw-score');
      teams[j].classList.add('draw-score');
    };
    i += 2;
    j += 2;
  });
});



