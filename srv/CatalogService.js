module.exports = cds.service.impl(async function(){
    //it will look our CatalogService.cds file and get the object
    //of the corresponding entity so that we can tell capm which 
    //entity we want to add generic handler
    const {EmployeSet , POs} = this.entities;
    
    this.before(['CREATE','UPDATE'],EmployeSet,(req,res)=>{
        console.log("Here it is bro : "+JSON.stringify(req.data));
        var jsonData = req.data;
        if(jsonData.hasOwnProperty("salaryAmount")){
            const salary=parseFloat(req.data.salaryAmount);
            if(salary>1000000){
                req.error(500, "Bro, The salary can not be more than 1 million ");
            }
        }
    });
    this.after('READ',EmployeSet,(req,res)=>{
        console.log(JSON.stringify(res));
        var finalData = [];
        for (let i = 0; i < res.results.length; i++) {
            const element = res.results[i];
            element.salaryAmount = element.salaryAmount * 1.10;
            finalData.push(element);
        } // or use map function instead of loop ..for practice only
        finalData.push({
            "ID": "dummy",
            "nameFirst": "Michel",
            "nameLast": "Saylor"
        });
        res.results = finalData;
    });

    ///implimention for the function getMostExpensiveOrder
    this.on('getMostExpensiveOrder',async(req,res)=>{
        try {
            const tx = cds.tx(req);
            const myData = await tx.read(POs).orderBy({
                "GROSS_AMOUNT": 'desc'
            }).limit(1);
            return myData;
        } catch (error) {
            return "Hey People ! " +error.toString();
        }
    });

     this.on('getOrderDefault',async(req,res)=>{
        try {
            return {OVERALL_STATUS : 'N'}
        }catch (error) {
            return "Hey People ! " +error.toString();
        }
    });

    ///instance bound action
    this.on('boost',async(req,res)=>{
        try {
            //programmatically check at runtime , if the user have the Editor permission or not 
            req.user.is('Editor')||req.reject(403);
            const POID = req.params[0];
            console.log("Your PO id was "+ JSON.stringify(POID));
            const tx=cds.tx(req);
            await tx.update(POs).with({
                "GROSS_AMOUNT" : {'+=' : 20000}
            }).where(POID);
            //after modify , read the instance
            const reply= tx.read(POs).where(POID);
            return reply;
        } catch (error) {
            return "Hey People ! " +error.toString();
        }
    });



    // /instance bound action for setDelivered
   this.on('setDelivered', async (req) => {
    try {
        const POID = req.params[0];
        const tx = cds.tx(req);
        
        await tx.update(POs).with({
            "OVERALL_STATUS" : 'D' // Fixed double 'L'
        }).where(POID);
        // Read single record using SELECT.one
        const reply =  tx.read(POs).where(POID);
        return  reply;
    } catch (error) {
        req.error(500, error.message || error.toString());
    }
});
});