const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("TFT Employee contract", function() {
    let Employee, EmployeeContract, owner, addr1
    beforeEach(async function(){
        Employee = await ethers.getContractFactory("TFTEmployee");
        [owner,addr1] = await ethers.getSigners();
        EmployeeContract = await Employee.deploy();
    })
    
    describe('Deployment', function(){
        it('Should set right owner', async function(){
            expect(await EmployeeContract.owner()).to.equal(owner.address)
        })
    })

    describe('Adding an Employee', function(){
        it('Should be reverted because caller is not the owner', async function(){
            await expect(EmployeeContract.connect(addr1).addEmployee("Anurag","pathak.anurag@tftus.com",1201,3,"TFTEmployee",12,15,5,"SmartContract_Dev"),
            ).to.be.revertedWith('Ownable: caller is not the owner')
        })

        it('Check if the token is minted', async function(){
            await expect(EmployeeContract.connect(owner)._tokenIdCounter.current()).to.equal(1);
        })
    })
   
});