
function createParagraph () {
    let para = document.createElement('p');
    para.textContent = '你点击了这个按钮';
    document.body.appendChild(para);
}
const buttons = document.querySelectorAll('button');
for (let index = 0; index < buttons.length; index++) {
    buttons[index].addEventListener('click', createParagraph);
}

