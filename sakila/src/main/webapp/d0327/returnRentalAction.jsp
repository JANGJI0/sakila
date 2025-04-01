<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql. * " %>
<%
	int rentalId = Integer.parseInt(request.getParameter("rentalId"));

	// 1) mysql 드라이버 연결
	Class.forName("com.mysql.cj.jdbc.Driver");
	
	Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");
	
	String sql = "UPDATE rental SET return_date = NOW() WHERE rental_id = ? AND return_date IS NULL";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, rentalId);
	
	int row = stmt.executeUpdate();
	if(row == 1) {
			// 디버깅
			System.out.println("반납 성공");
	} else {
			System.out.print("이미 반납되었거나 잘못된 ID");
	}
	
	response.sendRedirect("/sakila/index.jsp");
%>