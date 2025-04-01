<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
	// controller
	// 로그인 되었는지 아닌지?
	Integer staffId = (Integer)session.getAttribute("loginStaff");
	
	if(staffId == null) { // 로그아웃 상태라면
		response.sendRedirect("/sakila/loginForm.jsp");
		return;
	}
	
	//  변수 받기
	Integer inventoryId = Integer.parseInt(request.getParameter("inventoryId"));
	Integer customerId = Integer.parseInt(request.getParameter("customerId"));
	Integer filmId = Integer.parseInt(request.getParameter("filmId"));
	Integer storeId = Integer.parseInt(request.getParameter("storeId"));

	// model 단
	
	// 1) mysql 드라이버 연결
	Class.forName("com.mysql.cj.jdbc.Driver");
	
	// 변수 받기
	Connection conn = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	
	// 2) connection(접속)하기
	conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");
	
	// 3) sql 준비
	String sql = "INSERT INTO rental(inventory_id, customer_id, staff_id, rental_date) VALUES (?, ?, ?, now(3))";
	
	stmt = conn.prepareStatement(sql);
	stmt.setInt(1, inventoryId);
	stmt.setInt(2, customerId);
	stmt.setInt(3, staffId);
	// 디버깅
	System.out.println(stmt);
	
	int row = stmt.executeUpdate();
	
	if(row == 1) {
			System.out.println("대여 완료");
	
	} else {
			
			System.out.println("대여 불가");
	}
	
	response.sendRedirect("/sakila/d0325/rentalList.jsp");
%>











