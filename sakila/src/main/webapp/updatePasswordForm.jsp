<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title></title>
</head>
<body>
<style>
    body {
      font-family: 'Arial', sans-serif;
      padding: 40px;
      background-color: #f9f9f9;
    }
    table {
      width: 400px;
      margin: 0 auto;
      border-collapse: collapse;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      background-color: #fff;
    }
    th, td {
      border: 1px solid #ddd;
      padding: 12px 16px;
      text-align: left;
    }
    th {
      background-color: #e0e0e0; /* 진한회색으로 */
      font-weight: bold;
      font-size: 16px;
    }
    td {
      background-color: #f0f0f0; /* 밝은 회색 */
      font-weight: 600;
      color: #444;
    }
    tr:nth-child(even) {
      background-color: #fafafa;
     }
    .center {
    text-align: center;
    margin-top: 20px;
    }
  </style>
	<form action="/sakila/updatePasswordAction.jsp">
	<table>
		<tr>
			<th>현재 비밀번호</th>
			<td><input type="password" name = password></td>
		</tr>
		<tr>
			<th>새로운 비밀번호</th>
			<td><input type="password" name = newPassword></td>
		</tr>
		<tr>
			<th>비밀번호 확인</th>
			<td><input type="password" name = passwordCheck></td>
		</tr>
	</table>
	<div class="center">
	<button style="text-align:center;" type="submit">비밀번호 변경</button>
	</div>
	</form>
</body>
</html>