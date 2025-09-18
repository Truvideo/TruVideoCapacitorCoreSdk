import { TruVideoSdkCore } from 'truvideo-capacitor-core-sdk';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    TruVideoSdkCore.echo({ value: inputValue })
}
