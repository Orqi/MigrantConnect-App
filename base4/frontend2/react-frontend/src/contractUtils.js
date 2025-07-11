import { Contract } from "ethers";
import MigrantABI from "./MigrantABI.json";

const abi = MigrantABI.abi; // ✅ Use only the ABI array

const contractAddress = "0x37657A4D05AEc89d0bC1C17f126a8bB89D014a4b";

export const getContractInstance = (signer) => {
  return new Contract(contractAddress, abi, signer);
};