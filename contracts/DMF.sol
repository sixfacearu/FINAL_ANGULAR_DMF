pragma solidity ^0.4.23;
import "./FundToken.sol";
import "./SafeMath.sol";
import "./DostrixToken.sol";
contract DMF 
{
    using SafeMath for uint256;
        uint256  InvestersTotalToken=0; //invester total token count
        uint256 public takecommission;
        address contractAddress; //Fundtoken
        address public newadd; 
//ArrayList
        address[] public ToatlportfolioMAddress; //Array for storing the each register PortfolioManager
        address[] public TotalInvestorAddress; //Array for storing the each register Investors

//Structure For PortfolioManager Details
        struct PortfolioDetails
        {
            uint256 Eth;
          address[] investerAddressForPortfolio;
            uint commissionForPortfolio;
        }
//Structure For Investor Details  
        struct InvestorDetails
        {
            address[] PortfolioHolders; 
            uint256 Eth;
            uint256 TokenCount;
        }

//Structure For MarketToken Purchase Details
       
//Mapping Area
//Map for getting and storing the PortfolioManager resgistration Details
        mapping(address => PortfolioDetails) public Portfolio ;
//map for getting and storing the Investor getting token details
        mapping(address=> InvestorDetails) public Investment;
      mapping(address => mapping( address =>  InvestorDetails)) public invester ; 
        
//Map for getting the MarketToken Purchase details by the Portfoliomanager
       mapping(address => address) public Purchase; 
//Portfoliomanager Sold Tokens Ether 
        mapping(address => uint256) public PM_soldTK_Ether; 
//Constructor For initialize the contract Owner Address and Contract Deployed Address
        constructor(address na) public payable
        {
            newadd=address(this);
            contractAddress=na;
        }
//Function For PortfolioManager Resgistration
        function PortfolioReg() public payable
        {
            uint256 add = msg.value.div(1 ether);
            uint256 a= (add.mul(10)).div(100);
            takecommission=takecommission.add(a);
            uint256 show = add.sub(a);
            Portfolio[msg.sender].Eth= Portfolio[msg.sender].Eth.add(show);
            PM_soldTK_Ether[msg.sender] = PM_soldTK_Ether[msg.sender].add(show);
            GetFundToken(msg.value,msg.sender);
        }
//Function For Getting the Fundtokens by the PortfolioManager
        function GetFundToken(uint256 value,address add) private
        {
            uint256 tokens = value.div(0.001 ether);
            FundToken(contractAddress).mintToken(msg.sender,tokens);
            ToatlportfolioMAddress.push(add);
        }
//Function For Getting the Contract Ether Balance 
        function GetBal()public view returns(uint256)
        {
            return newadd.balance.div(1 ether);
        }

    
 //Function For Buying the FundTokens by the Investor From the PortfolioManager
        function InvesterGetToken(address _add_) public payable
        {
            uint256 tokens = msg.value.div(0.1 ether);
            InvestersTotalToken=InvestersTotalToken.add(tokens);
            FundToken(contractAddress).transferFrom(_add_,msg.sender,tokens);
            TotalInvestorAddress.push(msg.sender);
            Investment[msg.sender].PortfolioHolders.push(_add_);
            Investment[msg.sender].Eth = Investment[msg.sender].Eth.add(msg.value/1 ether);
            invester[msg.sender][_add_].Eth=invester[msg.sender][_add_].Eth.add(msg.value);
            invester[msg.sender][_add_].TokenCount=invester[msg.sender][_add_].TokenCount.add(tokens);
            uint256 test = msg.value.div(1 ether);
             PM_soldTK_Ether[_add_] = PM_soldTK_Ether[_add_].add(test);
            Portfolio[_add_].Eth = Portfolio[_add_].Eth.add(test);
            Portfolio[_add_].investerAddressForPortfolio.push(msg.sender);
        }
//Function For Getting the Investor Balance of Tokens
        function getBalance(address a) public view returns(uint256)
        {
            return FundToken(contractAddress).balanceOf(a);
        }
        
 /** The dividends calculations
        Investor1 = (( Investor1_fund TK) / (Inves1_FUndTK + Inves2_FUndTK + ... )) * 90;
*/
//Function For issue the Dividends yo the User
        function Dividends() public  
        {
             uint256 dividendToken = 100; 
             uint256 PortfolioManagerprofit = 0;
            FundToken(contractAddress).mintToken(msg.sender,dividendToken); //minting the token 
            PortfolioManagerprofit = (dividendToken.mul(10)).div(100); //taking the portfolio share
            FundToken(contractAddress).mintToken(msg.sender,PortfolioManagerprofit);
            for(uint256 i=0;i<TotalInvestorAddress.length;i++)
            {
                uint256 b = (Investment[TotalInvestorAddress[i]].TokenCount.mul((dividendToken.sub(PortfolioManagerprofit)))).div(InvestersTotalToken);
               FundToken(contractAddress).mintToken(TotalInvestorAddress[i],b);
                FundToken(contractAddress).tokenDecrease(msg.sender,b);
            }
            
        }
        function ReturnTokenToPortfolioManager(address _add_,uint256 value)public payable
        {
             uint  TR;
            FundToken(contractAddress).transferFrom(msg.sender,_add_,value);
            TR = value.mul(0.1 ether);
           uint256 commissionForDmf= commissionForDmf.add((TR.mul(10)).div(100));
            takecommission = takecommission.add((commissionForDmf.div(1 ether)));
            Portfolio[_add_].commissionForPortfolio = Portfolio[_add_].commissionForPortfolio.add((TR.mul(10)).div(100)); 
            uint256 a= (TR.sub(commissionForDmf.add(Portfolio[_add_].commissionForPortfolio))).add(commissionForDmf);
            _add_.transfer(Portfolio[_add_].commissionForPortfolio);
           newadd.send(commissionForDmf);
            (msg.sender).transfer(a);
            invester[msg.sender][_add_].Eth= invester[msg.sender][_add_].Eth.sub(TR);
        }
        
        
        //fufunction for purchasing the tokens 
        
        function purchaseToken(address buyToken,uint256 amountoftoken) public{
           Purchase[msg.sender]=buyToken;
            uint256 total = amountoftoken * 0.1 ether;
            MarketToken(buyToken).transfer(address(this),amountoftoken);
            buyToken.send(total);
            
        }
        
        
        

//Function For Many PortfolioManager Details
        function values() public view returns(uint256,uint256)
        {
            return (ToatlportfolioMAddress.length,TotalInvestorAddress.length);
        }
    
//function for validating the portfoliomanager
         function PortfolioValidating(address add)public view returns(bool)
         {
            for(uint256 i=0;i<=ToatlportfolioMAddress.length;i++)
            {
                
            if(ToatlportfolioMAddress[i]==msg.sender){
           
                return true;
                }
            }
        }
       
    
}                                                                                                            
