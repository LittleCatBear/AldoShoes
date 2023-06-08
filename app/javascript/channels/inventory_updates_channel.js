import consumer from "channels/consumer";

consumer.subscriptions.create("InventoryUpdatesChannel", {
  connected() {
    console.log("Connected to InventoryUpdatesChannel");
  },

  disconnected() {
    console.log("Disconnected to InventoryUpdatesChannel");
  },

  received(data) {
    console.log(data);

    let inventoryElement = document.querySelector(
      `.inventory-count[data-inventory-id='${data.shoe_id}']`
    );

    if (inventoryElement) {
      inventoryElement.innerText = `Inventory: ${data.inventory}`;

      let buttonElement = document.querySelector(
        `.inventory-button[data-shoe-id='${data.shoe_id}']`
      );
      if (data.inventory < 5 && !buttonElement) {
        inventoryElement.classList.add("low-inventory");
        buttonElement = document.createElement("button");
        buttonElement.innerText = "Request Inventory";
        buttonElement.classList.add("inventory-button");
        buttonElement.setAttribute("data-shoe-id", data.shoe_id);
        buttonElement.addEventListener("click", () => {
          const shoeId = buttonElement.getAttribute("data-shoe-id");

          requestInventoryMutation(shoeId);
        });

        document
          .getElementById(`shoe-${data.shoe_id}`)
          .appendChild(buttonElement);
      } else if (data.inventory >= 5) {
        if (buttonElement) {
          buttonElement.remove();
        }
        inventoryElement.classList.remove("low-inventory");
      }

      if (data.inventory > 25) {
        inventoryElement.classList.add("high-inventory");
      } else {
        inventoryElement.classList.remove("high-inventory");
      }

      // Create a small visual indication of change
      inventoryElement.style.color = "blue";
      inventoryElement.style.fontSize = "larger";
      setTimeout(() => {
        inventoryElement.style.color = "";
        inventoryElement.style.fontSize = "initial";
      }, 2000);
    }
  },
});

function requestInventoryMutation(shoeId) {
  fetch("/graphql", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
    },
    body: JSON.stringify({
      query: `
        mutation TransferInventory($toShoeId: ID!) {
          transferInventory(input: { toShoeId: $toShoeId }) {
            shoe {
              id
              model
              inventory
            }
            errors
          }
        }
      `,
      variables: {
        toShoeId: shoeId,
      },
    }),
  })
    .then((response) => response.json())
    .then((response) => {
      console.log(response);
      if (response.errors) {
        console.error(response.errors);
      }
    });
}
