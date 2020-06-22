﻿<%@ Page Title="" Language="C#" MasterPageFile="index.Master" AutoEventWireup="true" CodeBehind="blog.aspx.cs" Inherits="esayer.views.WebForm2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        $(function () {
            //用来显示手机版 图标
            $("#title span").text("");
            $("#title svg use").attr("xlink:href", "#icon-wenzhang");

            //ajax获取该blog
            var urlStr = window.location.search;
            var blogId = urlStr.substr(1);
            urlStr = "blog/" + blogId;
            $.ajax({
                type: 'get',
                url: url(urlStr),
                cache: false,
                data: {},
                dataType: 'json',
                beforeSend: function () {
                    $('#loadmodal').modal('show');
                },
                success: function (data) {
                    var res = data;
                    switch (res.status) {
                        //获取成功
                        case 200:
                            //渲染
                            //渲染标题
                            console.log(res);
                            var objMap = res.obj;
                            var blog = objMap.blog;
                            var blogShow = $('<div id ="title-name"><h1>' + blog.topic + '</h1></div><div id="title-info" class="d-flex justify-content-end"><div class="mr-3"><svg class="icon" aria-hidden="true"><use xlink:href="#icon-chakan"></use></svg>' + blog.clickNum + '</div><div><svg class="icon" aria-hidden="true"><use xlink:href="#icon-pinglun"></use></svg>' + blog.commentNum + '</div></div>');
                            $("#article-title").append(blogShow);

                            var user = objMap.user;
                            var userShow = $('<div><img src="' + user.headPic + '" width="45" height="45" /></div><div class="ml-2"><div><a class="text-success mr-2 text-decoration-none" href="user.aspx?' + user.userId + '">' + user.nickName + '</a></div><div>' + blog.createTime + '</div></div>');
                            $("#user-info").append(userShow);

                            $("#article").append(blog.content);

                            var articleOp = $('<div class="d-flex justify-content-center flex-column"><div class="d-flex justify-content-center text-info"  data-toggle="tooltip" data-placement="top" title="点赞"><svg class="icon" aria-hidden="true"><use xlink:href="#icon-dianzan1"></use></svg></div><div class="text-center">' + blog.starNum + '</div></div><div class="ml-2 mr-2"><div class="d-flex justify-content-center text-info" data-toggle="tooltip" data-placement="top" title="收藏"><svg class="icon" aria-hidden="true"><use xlink:href="#icon-shoucang1"></use></svg></div><div class="text-center">' + blog.collectionNum + '</div></div><div><div class="d-flex justify-content-center  text-info" data-toggle="tooltip" data-placement="top" title="转发"><svg class="icon" aria-hidden="true"><use xlink:href="#icon-fenxiang"></use></svg></div><div class="text-center">0</div></div>');
                            $("#article-op").append(articleOp);

                            var commentList = objMap.commentList;
                            console.log(commentList.length);
                            for (var i in commentList) {
                                commentList[i].createTime = getDateDiff(commentList[i].createTime);
                                $("#comment-list").append('<li class="list-group-item"><div class="d-flex"><div><img src="' + commentList[i].headPic + '" width="45px" height="45px" /></div><div class="d-flex ml-2 flex-column mb-2"><div><a class="text-info mr-2 text-decoration-none" href="user.aspx?' + commentList[i].userId + '">' + commentList[i].nickName + '</a></div><div class=" text-center bg-light rounded">' + commentList[i].createTime + '</div></div></div><div>' + commentList[i].content + '</div></li>');
                            }
                            if (commentList.length == 0) {
                                $("#sort-rule").html('<div class="text-center flex-grow-1"><p>暂时还没有评论，快来抢沙发吧~</p></div>')
                            }
                            break;
                        case 500:

                            break;
                    }

                },
                complete: function () {
                    $("#ContentPlaceHolder1_submit").attr('disabled', false);

                    //完美关闭模态框
                    $('#loadmodal').modal('hide');
                    $('#loadmodal').on('shown.bs.modal', function () {
                        $('#loadmodal').modal('hide');
                    });
                },
                error: function () {
                    swal({
                        title: "服务器繁忙",
                        text: "请稍后重试",
                        icon: "error",
                    });
                }
            });
            $("#comment").click(function () {
                swal({
                    text: "请输入评论内容",
                    content: "input",
                }).then((input) => {
                    if (;!input.replace(/&nbsp;/g, '').trim();) {
                        swal({
                            title: "输入不能为空",
                            text: " ",
                            icon: "warning",
                            buttons: false,
                            timer: 500,
                        });
                    } else {
                        $.ajax({
                            type: 'post',
                            url: url("comment"),
                            cache: false,
                            dataType: 'json',
                            data: {
                                blogId: blogId,
                                userId: JSON.parse(localStorage.getItem("user")).userId,
                                content: input,
                            },
                            beforeSend: function (req) {
                                //设置token
                                req.setRequestHeader("token", localStorage.getItem("token"));
                                $('#loadmodal').modal('show');
                            },
                            success: function (data) {
                                var res = data;
                                switch (res.status) {
                                    //评论成功
                                    case 200:
                                        swal({
                                            title: "评论成功",
                                            text: " ",
                                            icon: "success",
                                            buttons: false,
                                            timer: 800,
                                        });
                                        setInterval(function () {
                                            window.location.reload();
                                        }, 800);
                                        break;
                                    case 500:
                                        switch (res.msg) {
                                            //token失效
                                            case "tokenError":
                                                getToken();
                                                break;
                                            default:
                                                swal({
                                                    title: "服务器繁忙",
                                                    text: " ",
                                                    icon: "error",
                                                    buttons: true,
                                                });
                                        }
                                        break;
                                }

                            },
                            complete: function () {
                                console.log("执行完成");
                                $("#ContentPlaceHolder1_submit").attr('disabled', false);

                                //完美关闭模态框
                                $('#loadmodal').modal('hide');
                                $('#loadmodal').on('shown.bs.modal', function () {
                                    console.log("完全可见");
                                    $('#loadmodal').modal('hide');
                                });
                            },
                            error: function () {
                                swal({
                                    title: "服务器繁忙",
                                    text: "请稍后重试",
                                    icon: "error",
                                });
                            }
                        });
                    }
                })
            });
        })
    </script>
    <style type="text/css">
        #content {
        }

        #article-op svg:hover {
            cursor: pointer;
            color: aqua;
        }

        #split-bar {
            height: 30px;
            background-color: #f4f5f7;
        }

        #comment-list {

        }
        #article img{
            max-width:100%;
            max-height:100%;
        }

    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ContentPlaceHolder2" runat="server">
    <div class="modal fade" id="loadmodal">
        <div class="modal-dialog">
            <div class="modal-content bg-loader">
                <div class="modal-body d-flex justify-content-center align-items-center flex-column">
                    <div class="loader"></div>
                    <div class="text-white">世界上最远的距离是前端和后端</div>
                </div>
            </div>
        </div>
    </div>
    <div id="content">
        <div id="article-title">
        </div>
        <div id="user-info" class="card p-2 d-flex flex-row bg-light border-0">
        </div>
        <div id="article" class="mt-3">
        </div>
        <div id="article-op" class="d-flex mt-3 justify-content-center align-content-center">
        </div>
        <!--回复列表-->
        <div class="mt-3">
            <div id="releastBtn" class="d-flex justify-content-center m-2">
                <a id="comment" class="btn text-dark btn-block" style="background-color: #ccc">
                    <svg class="icon" aria-hidden="true">
                        <use xlink:href="#icon-pinglun3"></use>
                    </svg>
                    我来说一句
                </a>
            </div>
        </div>
        <div id="sort-rule" class="mt-2 d-flex text-secondary">
            <div class="btn-group" role="group" aria-label="Basic example">
                <button type="button" class="btn btn-link btn-sm text-decoration-none">综合</button>
                <button type="button" class="btn btn-link btn-sm text-decoration-none">按热度</button>
                <button type="button" class="btn btn-link btn-sm text-decoration-none">按时间</button>
            </div>
        </div>
        <div class="card d-flex border-0">
            <ul id="comment-list" class="list-group mb-3">
                
            </ul>
        </div>

    </div>
</asp:Content>
