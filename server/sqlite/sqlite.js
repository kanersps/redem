//                                     Licensed under                                     //
// Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License //

const updateUser = (identifier, newData) => {
    for(key in newData){
        emit("es_sqlite:updateUserData", identifier, key, newData[key])
    }
}

on("es_sqlite:updateUser", updateUser)