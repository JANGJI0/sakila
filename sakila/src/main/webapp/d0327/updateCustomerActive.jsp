<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
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
	Integer customerId = Integer.parseInt(request.getParameter("customerId"));
	
	int active = Integer.parseInt(request.getParameter("active"));
		// 디버깅
		System.out.println("변경 전 active: " + active);
	int i = 0; // 입력받은 active를 0 -> 1 / 1 -> 0으로 변경
	if(active == i) {
			active = 1;
	} else {
			active = 0;
	}
		//디버깅
		System.out.println("변경 후 active: " + active);
		System.out.println("customerId: " + customerId);
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
	String sql = "UPDATE customer SET active = ? WHERE customer_id = ?";
	
	stmt = conn.prepareStatement(sql);
	stmt.setInt(1, active);
	stmt.setInt(2, customerId);
	
	int row = 0;
		// 디버깅
		System.out.println(stmt);
	row = stmt.executeUpdate();
	
	if(row == 0) {
		response.sendRedirect("/sakila/d0325/rentalList.jsp");
			System.out.println("변경 실패");
	} else {
		response.sendRedirect("/sakila/d0325/rentalList.jsp");
			System.out.println("변경 완료");
	}
	
%>




















