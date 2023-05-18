import * as net from "net";

const server_ip = "IP_HERE";
const server_port = 80;

const client = new net.Socket();

client.connect(server_port, server_ip, () => {
  console.log("Connected to server");
  client.write("Hello from TypeScript TCP client!");
});

client.on("data", (data) => {
  console.log(data.toString());
  //client.destroy(); // Close the connection after receiving data
});

client.on("close", () => {
  console.log("Connection closed");
});

client.on("error", (err) => {
  console.log("Error:", err.message);
});

// Send a command to the server
function sendCommand(command: string) {
    client.write(command);
  }
  
  // Set up the input stream to read user input
  process.stdin.setEncoding('utf8');
  
  // Handle user input
  process.stdin.on('data', (input) => {
    const command = input.toString().trim();
    if (command === 'exit') {
      // Close the TCP connection and exit the program
      client.end();
      process.exit();
    } else {
      // Send the command to the server
      sendCommand(command);
    }
  });
  
  // Start listening for user input
  console.log('Enter a command (type "exit" to quit):');
  process.stdin.resume();
