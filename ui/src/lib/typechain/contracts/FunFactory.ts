/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumberish,
  BytesLike,
  FunctionFragment,
  Result,
  Interface,
  AddressLike,
  ContractRunner,
  ContractMethod,
  Listener,
} from "ethers";
import type {
  TypedContractEvent,
  TypedDeferredTopicFilter,
  TypedEventLog,
  TypedListener,
  TypedContractMethod,
} from "../common";

export interface FunFactoryInterface extends Interface {
  getFunction(nameOrSignature: "createFun" | "getFunByMan"): FunctionFragment;

  encodeFunctionData(
    functionFragment: "createFun",
    values: [
      string,
      string,
      string,
      AddressLike,
      BigNumberish,
      BigNumberish,
      BigNumberish
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "getFunByMan",
    values: [AddressLike]
  ): string;

  decodeFunctionResult(functionFragment: "createFun", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "getFunByMan",
    data: BytesLike
  ): Result;
}

export interface FunFactory extends BaseContract {
  connect(runner?: ContractRunner | null): FunFactory;
  waitForDeployment(): Promise<this>;

  interface: FunFactoryInterface;

  queryFilter<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEventLog<TCEvent>>>;
  queryFilter<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEventLog<TCEvent>>>;

  on<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    listener: TypedListener<TCEvent>
  ): Promise<this>;
  on<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    listener: TypedListener<TCEvent>
  ): Promise<this>;

  once<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    listener: TypedListener<TCEvent>
  ): Promise<this>;
  once<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    listener: TypedListener<TCEvent>
  ): Promise<this>;

  listeners<TCEvent extends TypedContractEvent>(
    event: TCEvent
  ): Promise<Array<TypedListener<TCEvent>>>;
  listeners(eventName?: string): Promise<Array<Listener>>;
  removeAllListeners<TCEvent extends TypedContractEvent>(
    event?: TCEvent
  ): Promise<this>;

  createFun: TypedContractMethod<
    [
      name: string,
      symbol: string,
      imageURI: string,
      raisinToken: AddressLike,
      endsAt: BigNumberish,
      maxSupply: BigNumberish,
      raisinTarget: BigNumberish
    ],
    [string],
    "nonpayable"
  >;

  getFunByMan: TypedContractMethod<[funder: AddressLike], [string[]], "view">;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "createFun"
  ): TypedContractMethod<
    [
      name: string,
      symbol: string,
      imageURI: string,
      raisinToken: AddressLike,
      endsAt: BigNumberish,
      maxSupply: BigNumberish,
      raisinTarget: BigNumberish
    ],
    [string],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "getFunByMan"
  ): TypedContractMethod<[funder: AddressLike], [string[]], "view">;

  filters: {};
}