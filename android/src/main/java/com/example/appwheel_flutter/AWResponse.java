package com.example.appwheel_flutter;

import java.io.Serializable;

/**
 * @author: Mr.H
 * @date: 2021/11/11
 */
public class AWResponse <T> implements Serializable {

    public boolean result;
    public T data;
    public String msg;

    public AWResponse(boolean result, T data, String msg) {
        this.result = result;
        this.data = data;
        this.msg = msg;
    }
}
