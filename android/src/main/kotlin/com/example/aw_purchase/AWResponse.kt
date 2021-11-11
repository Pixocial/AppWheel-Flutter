package com.example.aw_purchase

/**

@author: Mr.H
@date: 2021/10/28
 */
data class AWResponse <T>(val result: Boolean,
                      val data: T,
                      var msg: String) {
//    override fun toString(): String {
//        msg = if (msg.isNullOrEmpty()){""}else{msg}
//        return "{\"result\":$result,\"data\":${if(data.isNotEmpty()){data}else{"\"\""}}," +
//                "\"msg\":$msg}"
//    }
}
