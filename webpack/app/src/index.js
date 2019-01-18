import Web3 from "web3";
import lifelineArtifact from "../../build/contracts/LifeLine.json";

const App = {
  web3: null,
  account: null,
  chain: null,

  start: async function() {
    const { web3 } = this;

    try {
      // get contract instance
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = lifelineArtifact.networks[networkId];
      this.chain = new web3.eth.Contract(
        lifelineArtifact.abi,
        deployedNetwork.address,
      );
      
      // get accounts
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];
      console.log(this.account);
    //   this.refreshBalance();
    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }
  },

  login: async function() {
    const { getUserPwd } = this.chain.methods;
    const type = document.getElementById("selector1").value;
    const json = await getUserPwd(document.getElementById("account1").value, type).call();
    console.log(json);
    if(json[0] == false) {
        document.getElementById('msg11').style.display="";
        document.getElementById('msg12').style.display="none";
    } else {
        if(json[1] != document.getElementById("password1").value) {
            document.getElementById('msg11').style.display="none";
            document.getElementById('msg12').style.display="";
        } else {
            const userAccount = document.getElementById("account1").value;
            window.localStorage.setItem("data", userAccount);
            switch(type) {
                case "0": {
                    window.location.href="customer.html";break;
                }
                case "1": {
                    window.location.href="producer.html";break;
                }
                case "2": {
                    window.location.href="dealer.html";break;
                }
                case "3": {
                    window.location.href="retailer.html";break;
                }
            }
        }
        
    } 
  },
  register: async function() {
    const { newUser } = this.chain.methods;
    const account = document.getElementById("account2").value;
    const pwd = document.getElementById("password2").value;
    const name = document.getElementById("name2").value;
    const info = document.getElementById("info2").value;
    const type = document.getElementById("selector2").value;

    const res = await newUser(account, pwd, type, name, info).send({from: this.account, gas: 1000000});
    let isSuccess = res.events.NewUser.returnValues.isSuccess;
    let message = res.events.NewUser.returnValues.message;
    console.log(isSuccess, message);
    if(isSuccess == true) {
        alert(message);
        window.location.href="index.html";
    } else {
        document.getElementById("msg21").style.display = "";
    }
  },
  produce: async function() {
    const { produceGood } = this.chain.methods;
    const goodId = document.getElementById("goodId").value;
    const goodName = document.getElementById("goodName").value;
    const src = document.getElementById("owner").innerHTML;
    let components = [];
    if(document.getElementById("goodComponents").value.length != 0) {
        components = document.getElementById("goodComponents").value.split('/');
    }
    var date = new Date();
    var seperator1 = "-";
    var seperator2 = ":";
    var month = date.getMonth() + 1;
    var strDate = date.getDate();
    if (month >= 1 && month <= 9) {
        month = "0" + month;
    }
    if (strDate >= 0 && strDate <= 9) {
        strDate = "0" + strDate;
    }
    const currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate
            + " " + date.getHours() + seperator2 + date.getMinutes()
            + seperator2 + date.getSeconds();
    const res = await produceGood(goodId, goodName, src, components, currentdate).send({from: this.account, gas: 1000000});
    let isSuccess = res.events.ProduceGood.returnValues.isSuccess;
    let message = res.events.ProduceGood.returnValues.message;
    if(isSuccess) {
        alert(message);
        document.getElementById("goodId").value = "";
        document.getElementById("goodName").value = "";
        document.getElementById("goodComponents").value = "";
    } else {
        alert(message);
    }
  },
  query: async function() {
    const {queryGood} = this.chain.methods;
    const goodId = document.getElementById("goodId").value;
    const res = await queryGood(goodId).send({from: this.account, gas: 1000000});
    let isSuccess = res.events.QueryGood.returnValues.isSuccess;
    let message = res.events.QueryGood.returnValues.message;
    if(isSuccess == true) {
        let json =JSON.parse(message.replace(new RegExp("'","gm"),"\""));
        let tb1 = document.getElementById("alternatecolor1");
        tb1.rows[1].cells[0].innerHTML = json.ID;
        tb1.rows[1].cells[1].innerHTML = json.Name;
        tb1.rows[1].cells[2].innerHTML = json.ProduceTime;
        let tb2 = document.getElementById("alternatecolor2");
        tb2.rows[1].cells[0].innerHTML = json.Producer[0].Name;
        tb2.rows[1].cells[1].innerHTML = json.Producer[0].Info;
        let tb3 = document.getElementById("alternatecolor3");
        let counter = 0;
        for(var item in json.Sales) {
            if(item != 0) {
                let newrow3 = tb3.insertRow(1+counter);
                document.getElementById("ths").rowSpan = 2+counter+"";
                newrow3.innerHTML='<td></td><td></td><td></td><td></td>';
            }
            tb3.rows[1+counter].cells[0].innerHTML = json.Sales[item].BuyerType;
            tb3.rows[1+counter].cells[1].innerHTML = json.Sales[item].Buyer;
            tb3.rows[1+counter].cells[2].innerHTML = json.Sales[item].Time;
            tb3.rows[1+counter].cells[3].innerHTML = json.Sales[item].Price;
            counter++;
        }
        altRows('alternatecolor3');
        let tb4 = document.getElementById("alternatecolor4");
        let components = json.Compenents.split("/");
        for(let i=0; i<components.length; i++) {
            if(i!=0) {
                let newrow4 = tb4.insertRow(1+i);
                document.getElementById("thc").rowSpan = 2+i+"";
                newrow4.innerHTML='<td></td>';
            }
            tb4.rows[1+i].cells[0].innerHTML = components[i];
        }
        altRows('alternatecolor4');
    } else {
        alert(message);
    }
  },
  sell: async function(arg) {
    const {sellGood} = this.chain.methods;
    const goodId = document.getElementById("goodId2").value;
    const saleId = document.getElementById("saleId").value;
    const buyer = document.getElementById("buyer").value;
    var date = new Date();
    var seperator1 = "-";
    var seperator2 = ":";
    var month = date.getMonth() + 1;
    var strDate = date.getDate();
    if (month >= 1 && month <= 9) {
        month = "0" + month;
    }
    if (strDate >= 0 && strDate <= 9) {
        strDate = "0" + strDate;
    }
    const currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate
            + " " + date.getHours() + seperator2 + date.getMinutes()
            + seperator2 + date.getSeconds();
    const price = document.getElementById("price").value;
    const type = document.getElementById("selector").value;
    const seller = document.getElementById("owner").innerHTML;
    const sellerType = arg;
    const res = await sellGood(goodId, saleId, buyer, currentdate, price, type, seller, sellerType).send({from: this.account, gas: 1000000});
    // let isSuccess = res.events.SellGood.returnValues.isSuccess;
    let message = res.events.SellGood.returnValues.message;
    alert(message);
    console.log(res);
  },

};

window.App = App;

window.addEventListener("load", function() {
  if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum);
    window.ethereum.enable(); // get permission to access accounts
  } else {
    console.warn(
      "No web3 detected. Falling back to http://127.0.0.1:7545. You should remove this fallback when you deploy live",
    );
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(
      new Web3.providers.HttpProvider("http://127.0.0.1:7545"),
    );
  }

  App.start();
});
