pragma solidity 0.5.17;
//pragma experimental ABIEncoderV2;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
    function sqrt(uint256 x) internal pure returns (uint256) {
        uint256 z = add(x >> 1, 1);
        uint256 y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z), z)) / 2);
        }
        return y;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract DynamicSwap is ERC20, ERC20Detailed {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    constructor() public ERC20Detailed("DynamicSwap", "dUSD", 18) {
        governance = msg.sender;
    }

    /***********************************|
    |        Variables && Events        |
    |__________________________________*/
    
    uint256 public fee = 0.99985e18;
    uint256 public protocolFee = 0;
    uint256 public constant A = 0.75e18;
    uint256 public constant BASE = 1e18;
    uint256 public totalWeight;
    IERC20[] public allCoins;
    mapping(address => uint256) public rate;
    mapping(address => uint256) public weight;
    mapping(address => bool) public coins;
    mapping(address => bool) public isController;

    address public governance;
    address public vault;

    event Swap(
        address indexed caller,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256         tokenAmountIn,
        uint256         tokenAmountOut
    );

    /***********************************|
    |            Governmence            |
    |__________________________________*/
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setFee(uint256 _fee, uint256 _protocolFee) external {
        require(msg.sender == governance, "!governance");
        require(_fee > 0.99e18 && _fee < 1e18); //0 < fee < 1%
        if(_protocolFee > 0)
            require(uint256(1e18).sub(_fee).div(_protocolFee) >= 2); //protocolFee <= 50% fee
        fee = _fee;
        protocolFee = _protocolFee;
    }

    function setVault(address _vault) external {
        require(msg.sender == governance, "!governance");
        vault = _vault;
    }

    function approveCoins(address _coin) external {
        require(msg.sender == governance, "!governance");
        require(coins[_coin] == false, "Already approved");
        coins[_coin] = true;
        allCoins.push(IERC20(_coin));
    }

    function setController(address _controller, bool _isController) external {
        require(msg.sender == governance, "!governance");
        isController[_controller] = _isController;
    }

    function seize(IERC20 token, uint256 amount) external {
        require(msg.sender == governance, "!governance");
        require(!coins[address(token)], "can't seize liquidity");
        token.safeTransfer(vault, amount);
    }

    /***********************************|
    |            Controller             |
    |__________________________________*/

    function setRate(address token, uint256 _rate) external {
        require(isController[msg.sender], "!controller");
        rate[token] = _rate;
    }

    function setWeight(address token, uint256 _weight) external {
        require(isController[msg.sender], "!controller");
        if(weight[token] != _weight) {
            totalWeight = totalWeight.add(_weight).sub(weight[token]);
            weight[token] = _weight;
        }
    }

    /***********************************|
    |         Getter Functions          |
    |__________________________________*/

    // Get all support coins
    function getAllCoins() public view returns (IERC20[] memory) {
        return allCoins;
    }

    // Calculate total pool value in USD
    function calcTotalValue() public view returns (uint256 value) {
        uint256 totalValue = uint256(0);
        for (uint256 i = 0; i < allCoins.length; i++) {
            totalValue = totalValue.add(balance(allCoins[i]));
        }
        return totalValue;
    }

    /***********************************|
    |        Exchange Functions         |
    |__________________________________*/

    function f(uint256 _x, uint256 x, uint256 y) internal pure returns (uint256 _y) {
        uint256 k;
        uint256 c;
        {
            uint256 u = x.add(y.mul(A).div(BASE));
            uint256 v = y.add(x.mul(A).div(BASE));
            k = u.mul(v);
            c = k.mul(BASE).div(A).sub(_x.mul(_x)); // -c
        }
        
        uint256 cst = A.add(uint256(1e36).div(A));
        uint256 _b = _x.mul(cst).div(BASE);

        uint256 D = _b.mul(_b).add(c.mul(4)); // b^2 - 4c

        _y = D.sqrt().sub(_b).div(2);
    }

    // Calculate output given exact input
    function getOutExactIn(uint256 input, uint256 x, uint256 y) public view returns (uint256 output) {
        uint256 _x = x.add(input.mul(fee).div(BASE));
        uint256 _y = f(_x, x, y);
        output = y.sub(_y);
    }

    // Calculate input given exact output
    function getInExactOut(uint256 output, uint256 x, uint256 y) public view returns (uint256 input) {
        uint256 _y = y.sub(output);
        uint256 _x = f(_y, y, x);
        input = _x.sub(x).mul(BASE).div(fee);
    }
    
    // normalize coin to 1 USD * 1e18
    function normalize(IERC20 token, uint256 amount) public view returns (uint256) {
        return amount.mul(rate[address(token)]).div(BASE);
    }
    
    // recover coin to original decimals 
    function recover(IERC20 token, uint256 amount) public view returns (uint256) {
        return amount.mul(BASE).div(rate[address(token)]);
    }
    
    // Contract balance of coin normalized to 1 USD * 1e18
    function balance(IERC20 token) public view returns (uint256) {
        uint256 _balance = token.balanceOf(address(this));
        return normalize(token, _balance);
    }

    function calcFee(uint256 input) internal {
        if(protocolFee > 0) {
            uint256 _fee = input.mul(protocolFee).div(1e18);
            _mint(vault, _fee);
        }
    }

    function swapExactAmountIn(IERC20 from, IERC20 to, uint256 input, uint256 minOutput, uint256 deadline) external returns (uint256 output) {
        require(block.timestamp <= deadline, "expired");
        
        uint256 fromReserve = balance(from);
        uint256 toReserve = balance(to);

        if(weight[address(from)] > weight[address(to)])
            fromReserve = fromReserve.mul(weight[address(to)]).div(weight[address(from)], "!coin");
        else if(weight[address(from)] < weight[address(to)])
            toReserve = toReserve.mul(weight[address(from)]).div(weight[address(to)], "!coin");

        output = getOutExactIn(normalize(from, input), fromReserve, toReserve);
        output = recover(to, output);

        require(output >= minOutput, "slippage");
        
        calcFee(normalize(from, input));
        from.safeTransferFrom(msg.sender, address(this), input);
        to.safeTransfer(msg.sender, output);

        emit Swap(msg.sender, address(from), address(to), input, output);
    }

    function swapExactAmountOut(IERC20 from, IERC20 to, uint256 maxInput, uint256 output, uint256 deadline) external returns (uint256 input) {
        require(block.timestamp <= deadline, "expired");
        
        uint256 fromReserve = balance(from);
        uint256 toReserve = balance(to);

        if(weight[address(from)] > weight[address(to)])
            fromReserve = fromReserve.mul(weight[address(to)]).div(weight[address(from)], "!coin");
        else if(weight[address(from)] < weight[address(to)])
            toReserve = toReserve.mul(weight[address(from)]).div(weight[address(to)], "!coin");

        input = getInExactOut(normalize(to, output), fromReserve, toReserve);
        input = recover(from, input);
        
        require(input <= maxInput, "slippage");

        calcFee(normalize(from, input));
        from.safeTransferFrom(msg.sender, address(this), input);
        to.safeTransfer(msg.sender, output);

        emit Swap(msg.sender, address(from), address(to), input, output);
    }
    
    function addLiquidityExactIn(IERC20 from, uint256 input, uint256 minOutput, uint256 deadline) external returns (uint256 output) {
        require(coins[address(from)]==true, "!coin");
        require(block.timestamp <= deadline, "expired");
        
        if (totalSupply() == 0)
            output = normalize(from, input);
        else {
            uint256 fromReserve = balance(from);
            uint256 toReserve = totalSupply().mul(weight[address(from)]).div(totalWeight);
            output = getOutExactIn(normalize(from, input), fromReserve, toReserve);
        }
        
        require(output >= minOutput, "slippage");
        
        from.safeTransferFrom(msg.sender, address(this), input);
        _mint(msg.sender, output);
        calcFee(normalize(from, input));

        emit Swap(msg.sender, address(from), address(this), input, output);
    }
    
    function addLiquidityExactOut(IERC20 from, uint256 maxInput, uint256 output, uint256 deadline) external returns (uint256 input) {
        require(coins[address(from)] == true, "!coin");
        require(block.timestamp <= deadline, "expired");
        
        if (totalSupply() == 0) {
            input = recover(from, output);
        } else {
            uint256 fromReserve = balance(from);
            uint256 toReserve = totalSupply().mul(weight[address(from)]).div(totalWeight);
            input = recover(from, getInExactOut(output, fromReserve, toReserve));
        }
        
        require(input <= maxInput, "slippage");

        from.safeTransferFrom(msg.sender, address(this), input);
        _mint(msg.sender, output);
        calcFee(normalize(from, input));
    
        emit Swap(msg.sender, address(from), address(this), input, output);
    }
    
    function removeLiquidityExactIn(IERC20 to, uint256 input, uint256 minOutput, uint256 deadline) external returns (uint256 output) {
        require(block.timestamp <= deadline, "expired");
        
        if(input == totalSupply())
            output = recover(to, balance(to));
        else {
            uint256 fromReserve = totalSupply().mul(weight[address(to)]).div(totalWeight);
            uint256 toReserve = balance(to);
            output = recover(to, getOutExactIn(input, fromReserve, toReserve));
        }
        
        require(output >= minOutput, "slippage");
        
        _burn(msg.sender, input);
        calcFee(input);
        to.safeTransfer(msg.sender, output);

        emit Swap(msg.sender, address(this), address(to), input, output);
    }
    
    function removeLiquidityExactOut(IERC20 to, uint256 maxInput, uint256 output, uint256 deadline) external returns (uint256 input) {
        require(block.timestamp <= deadline, "expired");
        
        uint256 fromReserve = totalSupply().mul(weight[address(to)]).div(totalWeight);
        uint256 toReserve = balance(to);
        input = getInExactOut(normalize(to, input), fromReserve, toReserve);
        
        require(input <= maxInput, "slippage");

        _burn(msg.sender, input);
        calcFee(input);
        to.safeTransfer(msg.sender, output);

        emit Swap(msg.sender, address(this), address(to), input, output);
    }
    /*
    function multicall(bytes[] calldata data) external returns(bytes[] memory returndata) {
        returndata = new bytes[](data.length);
        for(uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success, "tx failed");
            returndata[i] = result;
        }
    }
    */
}

interface Compound {
    function exchangeRateStored() external view returns (uint256);
    function underlying() external view returns (address);
}

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract Controller {
    using SafeMath for uint256;
    DynamicSwap public target = DynamicSwap(0x000000000000000000000000000000000000bEEF);

    function getCompoundPrice(address token) public view returns (uint256) {
        address underlying = Compound(token).underlying();
        uint8 decimals = ERC20Detailed(underlying).decimals();
        return Compound(token).exchangeRateStored().mul(1e8*1e18).div(uint256(10) ** decimals);
    }

    function getUniswapLPPrice() public view returns (uint256) { // todo : support all pairs
        IUniswapV2Pair pair = IUniswapV2Pair(0xAE461cA67B15dc8dc81CE7615e0320dA1A9aB8D5); 
        uint256 totalLP = pair.totalSupply();
        (uint112 dai, uint112 usdc, ) = pair.getReserves();
        //sqrt(a * b) * 2 <= a + b
        uint256 price = uint(dai).mul(uint(usdc)).mul(1e12).sqrt().mul(2).mul(1e18).div(totalLP);
        return price;
    }

    bool private _init;

    function init() external {
        require(!_init);
        _init = true;
        //DAI
        target.setWeight(0x6B175474E89094C44Da98b954EedeAC495271d0F, 1e18);
        target.setRate(0x6B175474E89094C44Da98b954EedeAC495271d0F, 1e18);
        //USDC
        target.setWeight(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 1e18);
        target.setRate(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 1e12*1e18);
        //cUSDC
        target.setWeight(0x39AA39c021dfbaE8faC545936693aC917d5E7563, 1e18);
        target.setRate(0x39AA39c021dfbaE8faC545936693aC917d5E7563, getCompoundPrice(0x39AA39c021dfbaE8faC545936693aC917d5E7563));
        //DAI-USDC Uniswap
        target.setWeight(0xAE461cA67B15dc8dc81CE7615e0320dA1A9aB8D5, 1e18);
        target.setRate(0xAE461cA67B15dc8dc81CE7615e0320dA1A9aB8D5, getUniswapLPPrice());
    }

    function work() external {
        uint256 newRate;
        uint256 rateStored;

        newRate = getCompoundPrice(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
        rateStored = target.rate(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
        if(newRate != rateStored) {
            target.setWeight(0x39AA39c021dfbaE8faC545936693aC917d5E7563, target.weight(0x39AA39c021dfbaE8faC545936693aC917d5E7563).mul(newRate).div(rateStored));
            target.setRate(0x39AA39c021dfbaE8faC545936693aC917d5E7563, newRate);
        }

        newRate = getUniswapLPPrice();
        rateStored = target.rate(0xAE461cA67B15dc8dc81CE7615e0320dA1A9aB8D5);
        if(newRate != rateStored) {
            target.setWeight(0xAE461cA67B15dc8dc81CE7615e0320dA1A9aB8D5, target.weight(0xAE461cA67B15dc8dc81CE7615e0320dA1A9aB8D5).mul(newRate).div(rateStored));
            target.setRate(0xAE461cA67B15dc8dc81CE7615e0320dA1A9aB8D5, newRate);
        }

    }

}
