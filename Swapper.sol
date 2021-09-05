const Swapper=artifacts.require("Swapper.sol");
const NFTContract1=artifacts.require("NFTContract1.sol");
const NFTContract2=artifacts.require("NFTContract2.sol");

const { expect } = require('chai');
//const { time } = require("@openzeppelin/test-helpers");
const truffleAssert = require('truffle-assertions');

contract("Swapper",accounts=>{
    const [deployerAccount, user1, user2, anotherUser]=accounts; 
    beforeEach(async function(){
        NFTContract1Instance=await NFTContract1.new();
        NFTContract2Instance=await NFTContract2.new();
        SwapperInstance=await Swapper.new();
        collectionAddress= await NFTContract1Instance.address;
    });

    it("Testcase 1 : check if account owns NFT",async ()=>{
        expect((await NFTContract1Instance.balanceOf(user1)).toNumber()).to.equals(1);
        expect((await NFTContract2Instance.balanceOf(user2)).toNumber()).to.equals(1);
    });

    it("Testcase 2 : Can call setAddress() ",async()=>{
       await SwapperInstance.setAddress(collectionAddress);
       CollectionAddress=await SwapperInstance.nft();
       expect(CollectionAddress.toString()).to.equals(collectionAddress);

    });

    it("Testcase 3 : Add aggreement",async() => {
        await SwapperInstance.setAddress(collectionAddress);
        await SwapperInstance.addAgreement(0,collectionAddress,user2,{from: user1});
        to=await SwapperInstance.agreementMap(collectionAddress,0);
        
        expect(to).to.equals(user2);
    });

    it("Testcase 4 : Reverts if anyone without token owner tries to call addAgreement()",async()=>{
        await truffleAssert.reverts(SwapperInstance.addAgreement(0,NFTContract1Instance.address,user2,{from: anotherUser}));
    });

    it("Testcase 5: testing in full flow",async()=>{
        collectionAddress= await NFTContract1Instance.address;
        await SwapperInstance.setAddress(collectionAddress);
        //User adding agreement through UI.
        await NFTContract1Instance.approve(SwapperInstance.address,0,{from:user1});
        await NFTContract1Instance.approve(SwapperInstance.address,1,{from:user2});

        await SwapperInstance.addAgreement(0,collectionAddress,user2,{from:user1});
        await SwapperInstance.addAgreement(1,collectionAddress,user1,{from:user2});

        await SwapperInstance.swap(0,1,user1,user2,collectionAddress,{from:user2});

        var1 =await NFTContract1Instance.ownerOf(0);
        var2 =await NFTContract1Instance.ownerOf(1);
        // see if tokens are swapped.
        console.log("owner Of token 0", String(var1));
        console.log("owner Of token 1", String(var2));

        expect(String(var1)).to.eq(user2);
        expect(String(var2)).to.eq(user1);
    });
});
