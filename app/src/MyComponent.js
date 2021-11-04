import React from "react";
import { newContextComponents } from "@drizzle/react-components";
//import { DrizzleContext } from "@drizzle/react-plugin";
import logo from "./logo.png";
//import PropTypes from "prop-types";

const { AccountData,ContractData, ContractForm } = newContextComponents;

export default ({ drizzle, drizzleState }) => {
  // destructure drizzle and drizzleState from props
  //console.log("drizzleState:", AccountData);
  //{console.log(drizzle)};
  var _currentPrice;

// console.log("web3:", drizzle.web3.eth.accounts.givenProvider.selectedAddress);
  const currentPrice = drizzle.contracts.KOIProject.methods.getPrice();
  currentPrice.call().then(function (value) {
    _currentPrice = value;
  });

  return (
    <div className="App">
      <div>
        <img src={logo} alt="KOI-logo" id="logo" />
        <h1>The core spirit of KOI Project.</h1>
        <p align="left">
          The core spirit of KOI Project is PLUR, which refers to Pluralism, a
          philosophical thinking in which it is believed that the world begins
          with a combination of multiple elements. PLUR also has an important
          symbolic meaning in global culture: Peace, Love, Unity and Respect,
          it's the best blessing for the entire human civilization.
        </p>
      </div>

      <div className="section">
      <h2>Active Account</h2>
            <AccountData
              drizzle={drizzle}
              drizzleState={drizzleState}
              accountIndex={0}
              units="ether"
              precision={3}
              render={({ address, balance, units }) => (
                <div>
                  <div>Your Address: <span style={{ color: "red" }}>{address}</span></div>
                  <div>Your Matic: <span style={{ color: "red" }}>{balance}</span>Matic</div>
                </div>
              )}
            />
      </div>

      <div className="section">
        <p>
          <strong>Total Supply: </strong>
          <ContractData
            drizzle={drizzle}
            drizzleState={drizzleState}
            contract="KOIProject"
            method="totalSupply"
          />{" "}
          / 30000{" "}
          <ContractData
            drizzle={drizzle}
            drizzleState={drizzleState}
            contract="KOIProject"
            method="symbol"
            hideIndicator
          />
        </p>

        <p>
          <strong>Final Provenance Proof: </strong>
          <ContractData
            drizzle={drizzle}
            drizzleState={drizzleState}
            contract="KOIProject"
            method="KOI_Provenance"
            hideIndicator
          />
        </p>
        <p>
          {" "}
          <strong>KOI current price:</strong>
          <ContractData
            drizzle={drizzle}
            drizzleState={drizzleState}
            contract="KOIProject"
            method="getPrice"
            render={(getPrice) => {
              return getPrice / 1e18;
            }}
          />{" "}
          Matic
        </p>
        <p>
          <div>
            <strong>Your Balance: </strong>
            <ContractData
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="KOIProject"
              method="balanceOf"
              methodArgs={[
                drizzle.web3.eth.accounts.givenProvider.selectedAddress,
              ]}
            />{" "}
            KOI
          </div>
        </p>
        <h3>Mint KOI now!!!</h3>
        <ContractForm
          drizzle={drizzle}
          contract="KOIProject"
          method="mint"
          labels={["How many KOI to mint"]}
          sendArgs={{ value: _currentPrice}}
        />
      </div>
    </div>
  );
};
