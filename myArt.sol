pragma solidity 0.6.2;

import "https://github.com/0xcert/ethereum-erc721/src/contracts/tokens/nf-token-metadata.sol";
import "https://github.com/0xcert/ethereum-erc721/src/contracts/ownership/ownable.sol";

/**
 * @dev This is an example contract implementation of NFToken with metadata extension.
 */
contract MyArtSale is
  NFTokenMetadata,
  Ownable
{
uint256[] tokensId;

  /**
   * @dev Contract constructor. Sets metadata extension `name` and `symbol`.
   */
  constructor()
    public
  {
    nftName = "Frank's Art Sale";
    nftSymbol = "FAS";
  }

  /**
   * @dev Mints a new NFT.
   * @param _to The address that will own the minted NFT.
   * @param _tokenId of the NFT to be minted by the msg.sender.
   * @param _uri String representing RFC 3986 URI.
   */
  function mint(
    address _to,
    uint256 _tokenId,
    string calldata _uri
  )
    external
    onlyOwner
  {
    super._mint(_to, _tokenId);
    super._setTokenUri(_tokenId, _uri);
    tokensId.push(_tokenId);
  }
  
  function ownedTokenslist(address _addr) public view returns(uint256[] memory){
      uint256[] memory list=new uint256[](tokensId.length);
      uint256 j=0;
      for(uint256 i=0;i<tokensId.length;i++){
          if(idToOwner[tokensId[i]]==_addr){
              list[j++]=tokensId[i];
          }
      }
      return list;
  }

}
