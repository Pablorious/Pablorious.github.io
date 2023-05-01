// Create the nav element
var navElement = document.createElement('nav');

// Create the info element
var infoElement = document.createElement('div');
infoElement.className = 'info';

var nameElement = document.createElement('div');
nameElement.className = 'name';
var nameLink = document.createElement('a');
nameLink.href = 'index.html';
nameLink.textContent = 'Pablo';
nameElement.appendChild(nameLink);

var asideElement = document.createElement('aside');
asideElement.textContent = 'Reboredo-Segovia';

infoElement.appendChild(nameElement);
infoElement.appendChild(asideElement);

// Create the menu element
var menuElement = document.createElement('div');
menuElement.className = 'menu';

var menuList = document.createElement('ul');

var menuItems = [
  { text: 'About', href: 'index.html' },
  { text: 'Web Experiments', href: 'experiments.html' },
  { text: 'Github', href: 'https://github.com/Pablorious' },
  { text: 'Linkedin', href: 'https://linkedin.com/in/pablo-reboredo-segovia' }
];

menuItems.forEach(function (item) {
  var menuItem = document.createElement('li');
  var menuItemLink = document.createElement('a');
  menuItemLink.href = item.href;
  menuItemLink.textContent = item.text;
  menuItem.appendChild(menuItemLink);
  menuList.appendChild(menuItem);
});

menuElement.appendChild(menuList);

// Create the social element
var socialElement = document.createElement('div');
socialElement.className = 'social';

var socialList = document.createElement('ul');

var socialItems = [
  { href: 'pabloreboredosegovia+website@gmail.com', imgSrc: 'e-mail.svg', alt: 'Email' },
  { href: 'https://twitter.com/Pablorious', imgSrc: 'twitter.svg', alt: 'Twitter' },
  { href: 'https://github.com/Pablorious', imgSrc: 'github.svg', alt: 'Github' },
  { href: 'https://linkedin.com/in/pablo-reboredo-segovia', imgSrc: 'linkedin.webp', alt: 'Linkedin' }
];

socialItems.forEach(function (item) {
  var socialItem = document.createElement('li');
  var socialItemLink = document.createElement('a');
  socialItemLink.href = item.href;
  var socialItemImg = document.createElement('img');
  socialItemImg.alt = item.alt;
  socialItemImg.width = 20;
  socialItemImg.height = 20;
  socialItemImg.src = item.imgSrc;
  socialItemLink.appendChild(socialItemImg);
  socialItem.appendChild(socialItemLink);
  socialList.appendChild(socialItem);
});

socialElement.appendChild(socialList);

// Append the elements to the nav element
navElement.appendChild(infoElement);
navElement.appendChild(menuElement);
navElement.appendChild(socialElement);

// Append the nav element to the body
document.body.appendChild(navElement);
