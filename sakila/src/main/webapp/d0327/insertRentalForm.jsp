<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql. *"%>
<% 	
	// staff 로그인 session 확인
		// 로그인 되었는지 아닌지?
	Integer staffId = (Integer)(session.getAttribute("loginStaff"));
			
	if(staffId == null) { // 로그인 안 한 상태라면
		response.sendRedirect("/sakila/loginForm.jsp");
		return;
	}
	
	
	Integer inventoryId = Integer.parseInt(request.getParameter("inventoryId"));
	Integer customerId = null;
	if(request.getParameter("customerId") != null) {
		customerId = Integer.parseInt(request.getParameter("customerId"));
	}
	 
	
	Connection conn = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	String sql = "SELECT i.inventory_id inventoryId, i.film_id filmId, f.title, i.store_id storeId FROM inventory i INNER JOIN film f ON i.film_id = f.film_id WHERE i.inventory_id=?";
	Class.forName("com.mysql.cj.jdbc.Driver");
	conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");
	stmt = conn.prepareStatement(sql);
	stmt.setInt(1, inventoryId);
	
	System.out.println(stmt);
	rs = stmt.executeQuery();
%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title></title>
</head>
<body>
	<h1>Insert Rental Inventory</h1>
	<%
		if(rs.next()) {
	%>
	<form action="/sakila/d0327/searchCustomIdList.jsp" method="post">
		<input type="hidden" name="inventoryId" value="<%=inventoryId %>">
		<input type="text" name="searchName">
		<button type="submit">이름으로 회원아이디 검색</button>
	</form>
	<!--  customerListByName.jsp -> insertRentalForm.jsp 
	-->
	<form action="/sakila/d0327/insertRentalAction.jsp" method="post">
		<table>
			<tr>
				<td>customerId</td>
				<td><input type="text" name="customerId" value="<%=customerId %>"></td>
			</tr>
			
			<tr>
				<td>inventoryId</td>
				<td><input type="text" name="inventoryId" value="<%=inventoryId %>" readonly></td>
			</tr>
			
			<tr>
				<td>filmId</td>
				<td><input type="text" name="filmId" value="<%=rs.getInt("filmId") %>" readonly> /</td>
				<td><%=rs.getString("title") %></td>
			</tr>
			
			<tr>
				<td>storeId</td>
				<td><input type="text" name="storeId" value="<%=rs.getInt("storeId") %>" readonly></td>
			</tr>
			
			<tr>
				<td>staffId</td>
				<td><input type="text" name="staffId" value="<%=staffId %>" readonly></td> <!-- (Integer)session.getAttribute("loginStaff")  -->
			</tr>
			
		</table>
		<button type="submit">대여하기</button>
		</form>
	<%
		}
	%>
</body>
</html>